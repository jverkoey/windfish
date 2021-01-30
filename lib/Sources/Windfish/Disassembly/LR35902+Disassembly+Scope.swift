import Foundation

extension Disassembler {
  func rewriteScopes(_ run: Disassembler.Run) {
    // Compute scope and rewrite function labels if we're a function.

    let registers8 = LR35902.Instruction.Numeric.registers8

    for runGroup in run.runGroups() {
      // TODO: Rewriting scopes can probably happen in parallel to disassembly.
      for run in runGroup {
        guard let visitedRange = run.visitedRange else {
          continue
        }

        trace(range: visitedRange) { instruction, currentLocation, cpu in
          switch instruction.spec {
          // MARK: Backward type propagation

          // When a typed address is loaded into, we back-propagate the type to any applicable instructions that mutated
          // the register being loaded into the typed address.
          //
          // Consider the following example:
          //
          // 0 ld a, $00       x- .a: .loadImmediateFromSourceLocation(0)
          // 1 or a, $01        - .a: .mutationAtSourceLocation(1)
          // 2 ld a, $80       x- .a: .loadImmediateFromSourceLocation(2)
          // 3 or a, 1          - .a: .mutationAtSourceLocation(3)
          // 4 ld [$ff40], a      no register trace
          //
          // Legend:
          // x-: The register's existing trace list is cleared before adding this line's traces.
          //  -: The line's trace is added to the register's trace list.
          //
          // $ff40 is typed as an LCDCF which is a binary bitmask, so we want the annotated representation to look like
          // so:
          //
          // 0 ld a, $00
          // 1 ld a, $01
          // 2 ld a, LCDCF_ON
          // 3 or a, LCDCF_BG_DISPLAY
          // 4 ld [$ff40], a
          //
          // Back-propagation occurs after line 4 is emulated. The LCDCF type is assigned to line 2 and 3 because both
          // loadImmediateFromSourceLocation and mutationAtSourceLocation qualify for type propagation. The type is not
          // propagated to line 0 or 1 because line 2's load statement erases any prior trace events on the register.
          //
          // Consider a similar example:
          //
          // 0 ld a, [$dd44]   x- .a: .loadFromAddress($dd44)
          // 1 or a, 1          - .a: .mutationAtSourceLocation(1)
          // 2 ld [$ff40], a      no register trace
          //
          // Note that both $dd44 and $ff40 can have a type and they don't necessarily have to be the same type. There
          // are five cases to evaluate:
          //
          // 1. $dd44 and $ff40's types match.        Line 1 will also assume the same type.
          // 2. $dd44 and $ff40's types differ.       We will prioritize the type of $ff40.
          // 3. $dd44 has no type, $ff40 has a type.  Line 1 will assume $ff40's type.
          // 4. $dd44 has a type, $ff40 does not.     Line 1 will assume $dd44's type.
          // 5. Neither address has a type.           Line 1 will assume no type.
          //
          // Aside: case 2 is somewhat of a coin-toss in terms of which type to prefer. This may need to be revisited
          // with more data at hand. The prioritization of later load statement types is a result of the fact that
          // back-propagation happens after forward-propagation.
          //
          // Assuming $dd44 and $ff40 have the same type of LCDCF, we want the output to look like so:
          //
          // 0 ld a, [$dd44]
          // 1 or a, LCDCF_BG_DISPLAY
          // 2 ld [$ff40], a
          //
          // Now let's consider a more complex case involving multiple registers.
          //
          // 0 ld a, $04        x- .a: .loadImmediateFromSourceLocation(0)
          // 1 ld b, a          x- .b: .loadImmediateFromSourceLocation(0)                               (copied from .a)
          // 2 or b, $01         - .b: .mutationAtSourceLocation(2)
          // 3 ld a, $80        x- .a: .loadImmediateFromSourceLocation(3)
          // 4 or a, b           - .a: .loadImmediateFromSourceLocation(0), .mutationAtSourceLocation(2) (appended from .b)
          // 5 or a, $02         - .a: .mutationAtSourceLocation(5)
          // 6 ld [$ff40], a       no register trace
          //
          // By the end of this trace, register .a has an interesting trace list:
          //
          // - .loadImmediateFromSourceLocation(3)
          // - .loadImmediateFromSourceLocation(0)
          // - .mutationAtSourceLocation(2)
          // - .mutationAtSourceLocation(5)
          //
          // Note how register .b's load and mutation were appended into register .a's trace list. This enables
          // back-propagation for .a to apply to .b's traces as well.
          //
          // When we apply the type to all of register .a's traces we get the following output:
          //
          // 0 ld a, LCDCF_OBJ_16_16
          // 1 ld b, a
          // 3 or b, LCDCF_BG_DISPLAY
          // 4 ld a, LCDCF_ON
          // 5 or a, b
          // 6 or a, LCDCF_OBJ_DISPLAY
          // 7 ld [$ff40], a

          case .ld(.imm16addr, let register) where registers8.contains(register):
            guard case let .imm16(address) = instruction.immediate else {
              preconditionFailure("Invalid immediate associated with instruction")
            }
            if let global = self.configuration.global(at: address), let dataType = global.dataType,
              let registerTraces: [LR35902.RegisterTrace] = cpu.registerTraces[register] {
              registerTraces.forEach { (trace: LR35902.RegisterTrace) in
                switch trace {
                case .loadImmediateFromSourceLocation(.cartridge(let location)),
                     .mutationWithImmediateAtSourceLocation(.cartridge(let location)):
                  if self.typeAtLocation[location] == nil {
                    self.typeAtLocation[location] = dataType
                  }
                default:
                  break
                }
              }
            }
          case .ld(.ffimm8addr, let register) where registers8.contains(register):
            guard case let .imm8(addressLowByte) = instruction.immediate else {
              preconditionFailure("Invalid immediate associated with instruction")
            }
            let address = 0xFF00 | LR35902.Address(addressLowByte)
            if let global = self.configuration.global(at: address), let dataType = global.dataType,
              let registerTraces: [LR35902.RegisterTrace] = cpu.registerTraces[register] {
              registerTraces.forEach { (trace: LR35902.RegisterTrace) in
                switch trace {
                case .loadImmediateFromSourceLocation(.cartridge(let location)),
                     .mutationWithImmediateAtSourceLocation(.cartridge(let location)):
                  if self.typeAtLocation[location] == nil {
                    self.typeAtLocation[location] = dataType
                  }
                default:
                  break
                }
              }
            }

          // MARK: Forward type propagation

          // Forward propagation applies types to instructions if there are any address load traces in the register's
          // trace list that point to a typed address.
          //
          // Consider the following example:
          //
          // 0 ld a, [$dd44]   x- .a: .loadFromAddress($dd44)
          // 1 or a, 1          - .a: .mutationAtSourceLocation(1)
          //
          // When line 1 is traced, it looks at register .a's trace list for any .loadFromAddress traces.
          //
          // TODO: When multiple types can be applied to a source location this should be surfaced in the Windfish UI
          // as an opportunity for the user to resolve the ambiguity by selecting a type for that location. For now, we
          // just pick the first type.

          case .cp(.imm8),
               .add(.a, .imm8),
               .sub(.a, .imm8),
               .adc(.imm8),
               .sbc(.imm8),
               .or(.imm8),
               .xor(.imm8),
               .and(.imm8):
            if let registerTraces: [LR35902.RegisterTrace] = cpu.registerTraces[.a],
               let dataType: String = registerTraces.compactMap({ (trace: LR35902.RegisterTrace) -> String? in
                guard case .loadFromAddress(let address) = trace else {
                  return nil
                }
                guard let global = self.configuration.global(at: address), let dataType = global.dataType else {
                  return nil
                }
                return dataType
               }).first {
              // TODO: This previously had a (!type.namedValues.isEmpty || type.representation == .hexadecimal) check
              // Why was it necessary?
              if self.typeAtLocation[currentLocation] == nil {
                self.typeAtLocation[currentLocation] = dataType
              }
            }

          default:
            break
          }
        }
      }
      // Define the initial contiguous scope for the rungroup's label.
      // This allows functions to rewrite local labels as relative labels.
      guard let contiguousScope = runGroup.firstContiguousScopeRange else {
        continue
      }
      registerContiguousScope(range: contiguousScope)

      let headlessContiguousScope = contiguousScope.dropFirst()
      inferLoops(in: headlessContiguousScope)
      inferElses(in: headlessContiguousScope)
      inferReturns(in: headlessContiguousScope)
    }
  }

  private func inferReturns(in scope: Range<Cartridge.Location>) {
    let labelLocations = self.labelLocations(in: scope)
    let returnLabelAddresses = labelLocations.filter { instructionMap[$0]?.spec.category == .ret }
    for cartLocation in returnLabelAddresses {
      labelTypes[cartLocation] = .returnType
    }
  }

  private func inferLoops(in scope: Range<Cartridge.Location>) {
    let tocs: [(destination: Cartridge.Location, tocs: Set<Cartridge.Location>)] = scope.compactMap {
      if let toc = transfersOfControl(at: Cartridge.Location(address: $0.address, bank: $0.bank)) {
        return ($0, toc)
      } else {
        return nil
      }
    }
    let backwardTocs: [(source: Cartridge.Location, destination: Cartridge.Location)] = tocs.reduce(into: [], { (accumulator, element) in
      let tocsInThisScope = element.tocs.filter {
        scope.contains($0) && element.destination < $0
          && (labelNames[element.destination] != nil || labelTypes[element.destination] != nil)
      }
      for toc in tocsInThisScope {
        if case .jr(let condition, _) = instructionMap[toc]?.spec, condition != nil {
          accumulator.append((toc, element.destination))
        }
      }
    })
    if backwardTocs.isEmpty {
      return
    }
    // Loops do not include other unconditional transfers of control.
    let loops = backwardTocs.filter {
      let loopRange = ($0.destination..<$0.source)
      let tocsWithinLoop: [LR35902.Instruction] = tocs.flatMap {
        $0.tocs
          .filter { loopRange.contains($0) }
          .compactMap { instructionMap[$0] }
      }
      return !tocsWithinLoop.contains {
        switch $0.spec {
        case .jp(let condition, _), .ret(let condition):
          return condition == nil
        default:
          return false
        }
      }
    }
    if loops.isEmpty {
      return
    }
    let destinations = Set(loops.map { $0.destination })
    for location in destinations {
      labelTypes[location] = .loopType
    }
  }

  private func inferElses(in scope: Range<Cartridge.Location>) {
    let tocs: [(destination: Cartridge.Location, tocs: Set<Cartridge.Location>)] = scope.compactMap {
      if let toc = transfersOfControl(at: $0) {
        return ($0, toc)
      } else {
        return nil
      }
    }
    let forwardTocs: [(source: Cartridge.Location, destination: Cartridge.Location)] = tocs.reduce(into: [], { (accumulator, element) in
      let tocsInThisScope = element.tocs.filter {
        scope.contains($0)
          && element.destination > $0
          && (labelNames[element.destination] != nil || labelTypes[element.destination] != nil)
      }
      for toc in tocsInThisScope {
        if case .jr(let condition, _) = instructionMap[toc]?.spec, condition != nil {
          accumulator.append((toc, element.destination))
        }
      }
    })
    if forwardTocs.isEmpty {
      return
    }
    let destinations = Set(forwardTocs.map { $0.destination })
    for location in destinations {
      labelTypes[location] = .elseType
    }
  }
}
