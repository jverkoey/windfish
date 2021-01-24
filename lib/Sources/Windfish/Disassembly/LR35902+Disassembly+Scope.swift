import Foundation

extension Disassembler {
  func rewriteScopes(_ run: Disassembler.Run) {
    // Compute scope and rewrite function labels if we're a function.

    let registers8 = LR35902.Instruction.Numeric.registers8

    for runGroup in run.runGroups() {
      // TODO: We should do this after all disassembly has been done and before writing to disk.
      for run in runGroup {
        guard let visitedRange = run.visitedRange else {
          continue
        }

        // TODO: Make all registers on the LR35902 optional and AddressableMemory able to return nil in case memory is unknown.
        // We should only be registering traces when we're confident of the value of a register or the value in memory.

        trace(range: visitedRange) { instruction, currentLocation, cpu in
          switch instruction.spec {
          // MARK: Backward type propagation

          // When we load a register into a global with a type, treat the location where the register was originally
          // set as the global's type.
          case .ld(.imm16addr, let register) where registers8.contains(register):
            guard case let .imm16(address) = instruction.immediate else {
              preconditionFailure("Invalid immediate associated with instruction")
            }
            if let global = self.globals[address],
              let dataType = global.dataType,
              case let .cartridge(sourceLocation) = cpu.registerTraces[register]?.sourceLocation {
              self.typeAtLocation[sourceLocation] = dataType
            }
          case .ld(.ffimm8addr, let register) where registers8.contains(register):
            guard case let .imm8(addressLowByte) = instruction.immediate else {
              preconditionFailure("Invalid immediate associated with instruction")
            }
            let address = 0xFF00 | LR35902.Address(addressLowByte)
            if let global = self.globals[address],
              let dataType = global.dataType,
              case let .cartridge(sourceLocation) = cpu.registerTraces[register]?.sourceLocation {
              self.typeAtLocation[sourceLocation] = dataType
            }

            // MARK: Forward type propagation

            // When comparing against a, set the type of this instruction to the type of the global that was loaded into
            // a.
          case .cp(.imm8):
            if let loadAddress = cpu.registerTraces[.a]?.loadAddress,
              let global = self.globals[loadAddress],
              let dataType = global.dataType {
              self.typeAtLocation[currentLocation] = dataType
            }
          case .or(.imm8), .xor(.imm8), .and(.imm8):
            if let address = cpu.registerTraces[.a]?.loadAddress,
              let global = self.globals[address],
              let dataType = global.dataType,
              let type = self.dataTypes[dataType],
              (!type.namedValues.isEmpty || type.representation == .hexadecimal) {
              self.typeAtLocation[currentLocation] = dataType

              // Default to a binary representation for bit operations.
            } else if self.typeAtLocation[currentLocation] == nil {
              self.typeAtLocation[currentLocation] = "binary"
            }

          case .add(.a, .imm8):
            if let loadAddress = cpu.registerTraces[.a]?.loadAddress,
               let global = self.globals[loadAddress],
               let dataType = global.dataType {
              self.typeAtLocation[currentLocation] = dataType
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
