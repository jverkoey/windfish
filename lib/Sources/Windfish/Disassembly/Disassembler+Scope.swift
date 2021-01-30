import Foundation

extension Disassembler {
  func rewriteScopes(_ run: Disassembler.Run) {
    for runGroup: RunGroup in run.runGroups() {
      for run: Run in runGroup {
        propagateTypes(for: run)
      }
      // Define the initial contiguous scope for the rungroup's label.
      // This allows functions to rewrite local labels as relative labels.
      guard let contiguousScope: Range<Cartridge.Location> = runGroup.firstContiguousScopeRange else {
        continue
      }
      registerContiguousScope(range: contiguousScope)

      let headlessContiguousScope: Range<Cartridge.Location> = contiguousScope.dropFirst()

      let tocs: [(destination: Cartridge.Location, tocs: Set<Cartridge.Location>)] = headlessContiguousScope.compactMap {
        guard let toc: Set<Cartridge.Location> = transfersOfControl(at: $0) else {
          return nil
        }
        return ($0, toc)
      }
      inferDoWhiles(in: headlessContiguousScope, tocs: tocs)
      inferElses(in: headlessContiguousScope, tocs: tocs)
      inferReturns(in: headlessContiguousScope, tocs: tocs)
    }
  }

  private func propagateTypes(for run: Run) {
    guard let visitedRange: Range<Cartridge.Location> = run.visitedRange else {
      return
    }

    let registers8: Set<LR35902.Instruction.Numeric> = LR35902.Instruction.Numeric.registers8

    trace(range: visitedRange) { (instruction: LR35902.Instruction, currentLocation: Cartridge.Location, cpu: LR35902) in
      switch instruction.spec {

      // MARK: Backward type propagation

      case .ld(.imm16addr, let register) where registers8.contains(register):
        guard case let .imm16(address) = instruction.immediate else {
          preconditionFailure("Invalid immediate associated with instruction")
        }
        self.backPropagateTypeOfLoad(from: address, cpu: cpu, register: register)

      case .ld(.ffimm8addr, let register) where registers8.contains(register):
        guard case let .imm8(addressLowByte) = instruction.immediate else {
          preconditionFailure("Invalid immediate associated with instruction")
        }
        let address: LR35902.Address = 0xFF00 | LR35902.Address(addressLowByte)
        self.backPropagateTypeOfLoad(from: address, cpu: cpu, register: register)

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
        guard self.typeAtLocation[currentLocation] == nil else {
          break
        }
        guard let registerTraces: [LR35902.RegisterTrace] = cpu.registerTraces[.a],
              let dataType: String = registerTraces.lazy.compactMap({ (trace: LR35902.RegisterTrace) -> String? in
                guard case .loadFromAddress(let address) = trace else {
                  return nil
                }
                guard let global: Configuration.Global = self.configuration.global(at: address),
                      let dataType: String = global.dataType else {
                  return nil
                }
                return dataType
              }).first else {
          break;
        }
        // TODO: This previously had a (!type.namedValues.isEmpty || type.representation == .hexadecimal) check
        // Why was it necessary?
        self.typeAtLocation[currentLocation] = dataType

      default:
        break
      }
    }
  }

  private func inferReturns(in scope: Range<Cartridge.Location>, tocs: [(destination: Cartridge.Location, tocs: Set<Cartridge.Location>)]) {
    let returnLabelAddresses: [Cartridge.Location] = tocs.compactMap { (destination: Cartridge.Location, tocs: Set<Cartridge.Location>) -> Cartridge.Location? in
      guard instructionMap[destination]?.spec.category == .ret else {
        return nil
      }
      return destination
    }
    for cartLocation: Cartridge.Location in returnLabelAddresses {
      labelTypes[cartLocation] = .returnTransfer
    }
  }

  private func inferDoWhiles(in scope: Range<Cartridge.Location>, tocs: [(destination: Cartridge.Location, tocs: Set<Cartridge.Location>)]) {
    // Do-while loops are transfers of control that conditionally jump backward into the same contiguous scope.
    let backwardTocs: [(source: Cartridge.Location, destination: Cartridge.Location)] = tocs.reduce(into: [], { (accumulator, element) in
      for location: Cartridge.Location in element.tocs {
        guard scope.contains(location) && element.destination < location else {
          continue
        }
        switch instructionMap[location]?.spec {
        case .jr(let condition, _) where condition != nil,
             .jp(let condition, _) where condition != nil:
          accumulator.append((location, element.destination))
        default:
          break
        }
      }
    })
    if backwardTocs.isEmpty {
      return
    }
    // do-while loops do not include other unconditional transfers of control.
    let loops = backwardTocs.filter { (source: Cartridge.Location, destination: Cartridge.Location) -> Bool in
      let loopRange = (destination..<source)
      let tocsWithinLoop: [LR35902.Instruction] = tocs.flatMap { (destination: Cartridge.Location, tocs: Set<Cartridge.Location>) -> [LR35902.Instruction] in
        tocs.filter { loopRange.contains($0) }.compactMap { instructionMap[$0] }
      }
      return !tocsWithinLoop.contains(where: { (instruction: LR35902.Instruction) -> Bool in
        switch instruction.spec {
        case .jp(let condition, _),
             .ret(let condition):
          return condition == nil
        default:
          return false
        }
      })
    }
    if loops.isEmpty {
      return
    }
    let destinations: Set<Cartridge.Location> = Set(loops.map { $0.destination })
    for location: Cartridge.Location in destinations {
      labelTypes[location] = .doWhile
    }
  }

  private func inferElses(in scope: Range<Cartridge.Location>, tocs: [(destination: Cartridge.Location, tocs: Set<Cartridge.Location>)]) {
    // Else statements are transfers of control that jump forward into the same contiguous scope.
    let forwardTocs: [(source: Cartridge.Location, destination: Cartridge.Location)] = tocs.reduce(into: [], { (accumulator, element) in
      for location: Cartridge.Location in element.tocs {
        guard scope.contains(location) && element.destination > location else {
          continue
        }
        switch instructionMap[location]?.spec {
        case .jr(let condition, _) where condition != nil,
             .jp(let condition, _) where condition != nil:
          accumulator.append((location, element.destination))
        default:
          break
        }
      }
    })
    if forwardTocs.isEmpty {
      return
    }
    let destinations: Set<Cartridge.Location> = Set(forwardTocs.map { $0.destination })
    for location: Cartridge.Location in destinations {
      labelTypes[location] = .logicalElse
    }
  }

  // MARK: Backward type propagation

  /**
   When a typed address is loaded into, we back-propagate the type to any applicable instructions that mutated
   the register being loaded into the typed address.

   Consider the following example:

   ```
   0: ld a, $00       x- .a: .loadImmediateFromSourceLocation(0)
   1: or a, $01        - .a: .mutationAtSourceLocation(1)
   2: ld a, $80       x- .a: .loadImmediateFromSourceLocation(2)
   3: or a, 1          - .a: .mutationAtSourceLocation(3)
   4: ld [$ff40], a      no register trace
   ```

   Legend:

   ```
   x-: The register's existing trace list is cleared before adding this line's traces.
    -: The line's trace is added to the register's trace list.
   ```

   $ff40 is typed as an LCDCF which is a binary bitmask, so we want the annotated representation to look like
   so:

   ```
   0: ld a, $00
   1: ld a, $01
   2: ld a, LCDCF_ON
   3: or a, LCDCF_BG_DISPLAY
   4: ld [$ff40], a
   ```

   Back-propagation occurs after line 4 is emulated because of the load of `a` into the typed address: $ff40. The LCDCF
   type is assigned to line 2 and 3 because both loadImmediateFromSourceLocation and mutationAtSourceLocation qualify
   for type propagation. The type is not propagated to line 0 or 1 because line 2's load statement erases any prior
   trace events on the register.

   Consider a similar example:

   ```
   0: ld a, [$dd44]   x- .a: .loadFromAddress($dd44)
   1: or a, 1          - .a: .mutationAtSourceLocation(1)
   2: ld [$ff40], a      no register trace
   ```

   Note that both $dd44 and $ff40 can have a type and they don't necessarily have to be the same type. There
   are five cases to evaluate:

   1. $dd44 and $ff40's types match.        Line 1 will also assume the same type.
   2. $dd44 and $ff40's types differ.       We will prioritize the type of $ff40.
   3. $dd44 has no type, $ff40 has a type.  Line 1 will assume $ff40's type.
   4. $dd44 has a type, $ff40 does not.     Line 1 will assume $dd44's type.
   5. Neither address has a type.           Line 1 will assume no type.

   Aside: case 2 is somewhat of a coin-toss in terms of which type to prefer. This may need to be revisited
   with more data at hand. The prioritization of later load statement types is a result of the fact that
   back-propagation happens after forward-propagation.

   Assuming $dd44 and $ff40 have the same type of LCDCF, we want the output to look like so:

   ```
   0: ld a, [$dd44]
   1: or a, LCDCF_BG_DISPLAY
   2: ld [$ff40], a
   ```

   Now let's consider a more complex case involving multiple registers.

   ```
   0: ld a, $04        x- .a: .loadImmediateFromSourceLocation(0)
   1: ld b, a          x- .b: .loadImmediateFromSourceLocation(0)                               (copied from .a)
   2: or b, $01         - .b: .mutationAtSourceLocation(2)
   3: ld a, $80        x- .a: .loadImmediateFromSourceLocation(3)
   4: or a, b           - .a: .loadImmediateFromSourceLocation(0), .mutationAtSourceLocation(2) (appended from .b)
   5: or a, $02         - .a: .mutationAtSourceLocation(5)
   6: ld [$ff40], a       no register trace
   ```

   By the end of this trace, register .a has an interesting trace list:

   - .loadImmediateFromSourceLocation(3)
   - .loadImmediateFromSourceLocation(0)
   - .mutationAtSourceLocation(2)
   - .mutationAtSourceLocation(5)

   Note how register .b's load and mutation were appended into register .a's trace list. This enables
   back-propagation for .a to apply to .b's traces as well.

   When we apply the type to all of register .a's traces we get the following output:

   ```
   0: ld a, LCDCF_OBJ_16_16
   1: ld b, a
   3: or b, LCDCF_BG_DISPLAY
   4: ld a, LCDCF_ON
   5: or a, b
   6: or a, LCDCF_OBJ_DISPLAY
   7: ld [$ff40], a
   ```
  */
  private func backPropagateTypeOfLoad(from address: UInt16, cpu: LR35902, register: LR35902.Instruction.Numeric) {
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
  }

}
