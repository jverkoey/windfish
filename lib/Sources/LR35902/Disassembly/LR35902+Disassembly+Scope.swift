import Foundation

extension LR35902.Disassembly {
  func rewriteScopes(_ run: LR35902.Disassembly.Run) {
    // Compute scope and rewrite function labels if we're a function.

    let registers8 = LR35902.Instruction.Numeric.registers8

    for runGroup in run.runGroups() {
      // TODO: We should do this after all disassembly has been done and before writing to disk.
      for run in runGroup {
        guard let visitedRange = run.visitedRange else {
          continue
        }

        trace(range: visitedRange) { instruction, location, state in
          switch instruction.spec {
            // TODO: This only works if we're simulating the run as part of the linear sweep.
            // TODO: Fold the simulation logic into the linear sweep somehow.
//          case .ld(.imm16addr, let src) where registers8.contains(src):
//            if (0x2000..<0x4000).contains(instruction.imm16!),
//              let srcValue: CPUState.RegisterState<UInt8> = state[src],
//              case .value(let value) = srcValue.value {
//              let addressAndBank = LR35902.Cartridge.addressAndBank(from: location)
//              self.register(bankChange: value, at: addressAndBank.address, in: addressAndBank.bank)
//            }

          case .ld(.imm16addr, let numeric) where registers8.contains(numeric):
            guard case let .imm16(immediate) = instruction.immediate else {
              preconditionFailure("Invalid immediate associated with instruction")
            }
            if let global = self.globals[immediate],
              let dataType = global.dataType,
              let sourceLocation = state.a?.sourceLocation {
              self.typeAtLocation[sourceLocation] = dataType
            }

          case .ld(.ffimm8addr, let numeric) where registers8.contains(numeric):
            guard case let .imm8(immediate) = instruction.immediate else {
              preconditionFailure("Invalid immediate associated with instruction")
            }
            let address = 0xFF00 | LR35902.Address(immediate)
            if let global = self.globals[address],
              let dataType = global.dataType,
              let sourceLocation = state.a?.sourceLocation {
              self.typeAtLocation[sourceLocation] = dataType
            }

          case .cp(_):
            if let address = state.a?.variableLocation,
              let global = self.globals[address],
              let dataType = global.dataType {
              self.typeAtLocation[location] = dataType
            }

          case .ld(.ffimm8addr, let src) where registers8.contains(src):
            guard case let .imm8(immediate) = instruction.immediate else {
              preconditionFailure("Invalid immediate associated with instruction")
            }
            let address = 0xFF00 | LR35902.Address(immediate)
            if let global = self.globals[address],
              let dataType = global.dataType,
              let srcValue: LR35902.CPUState.RegisterState<UInt8> = state[src] {
              self.typeAtLocation[srcValue.sourceLocation] = dataType
            }

          case .and(.imm8):
            if let address = state.a?.variableLocation,
              let global = self.globals[address],
              let dataType = global.dataType,
              let type = self.dataTypes[dataType],
              (!type.namedValues.isEmpty || type.representation == .hexadecimal) {
              self.typeAtLocation[location] = dataType

            } else if self.typeAtLocation[location] == nil {
              self.typeAtLocation[location] = "binary"
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
      addContiguousScope(range: contiguousScope)

      let contiguousScopeWithoutFirstInstruction = contiguousScope.dropFirst()
      inferLoops(in: contiguousScopeWithoutFirstInstruction)
      inferElses(in: contiguousScopeWithoutFirstInstruction)
      inferReturns(in: contiguousScopeWithoutFirstInstruction)
    }
  }

  private func inferReturns(in scope: Range<LR35902.Cartridge.Location>) {
    let labelLocations = self.labelLocations(in: scope)
    let returnLabelAddresses = labelLocations.filter { instructionMap[$0]?.spec.category == .ret }
    for cartLocation in returnLabelAddresses {
      labelTypes[cartLocation] = .returnType
    }
  }

  private func inferLoops(in scope: Range<LR35902.Cartridge.Location>) {
    let tocs: [(destination: LR35902.Cartridge.Location, tocs: Set<TransferOfControl>)] = scope.compactMap {
      let (address, bank) = LR35902.Cartridge.addressAndBank(from: $0)
      if let toc = transfersOfControl(at: address, in: bank) {
        return ($0, toc)
      } else {
        return nil
      }
    }
    let backwardTocs: [(source: LR35902.Cartridge.Location, destination: LR35902.Cartridge.Location)] = tocs.reduce(into: [], { (accumulator, element) in
      let tocsInThisScope = element.tocs.filter {
        scope.contains($0.sourceLocation) && element.destination < $0.sourceLocation && (labels[element.destination] != nil || labelTypes[element.destination] != nil)
      }
      for toc in tocsInThisScope {
        if case .jr(let condition, _) = instructionMap[toc.sourceLocation]?.spec,
          condition != nil {
          accumulator.append((toc.sourceLocation, element.destination))
        }
      }
    })
    if backwardTocs.isEmpty {
      return
    }
    // Loops do not include other unconditional transfers of control.
    let loops = backwardTocs.filter {
      let loopRange = ($0.destination..<$0.source)
      let tocsWithinLoop = tocs.flatMap {
        $0.tocs.filter { loopRange.contains($0.sourceLocation) }.map { $0.sourceInstructionSpec }
      }
      return !tocsWithinLoop.contains {
        switch $0 {
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
    for cartLocation in destinations {
      labelTypes[cartLocation] = .loopType
    }
  }

  private func inferElses(in scope: Range<LR35902.Cartridge.Location>) {
    let tocs: [(destination: LR35902.Cartridge.Location, tocs: Set<TransferOfControl>)] = scope.compactMap {
      let (address, bank) = LR35902.Cartridge.addressAndBank(from: $0)
      if let toc = transfersOfControl(at: address, in: bank) {
        return ($0, toc)
      } else {
        return nil
      }
    }
    let forwardTocs: [(source: LR35902.Cartridge.Location, destination: LR35902.Cartridge.Location)] = tocs.reduce(into: [], { (accumulator, element) in
      let tocsInThisScope = element.tocs.filter {
        scope.contains($0.sourceLocation)
          && element.destination > $0.sourceLocation
          && (labels[element.destination] != nil || labelTypes[element.destination] != nil)
      }
      for toc in tocsInThisScope {
        if case .jr(let condition, _) = instructionMap[toc.sourceLocation]?.spec,
          condition != nil {
          accumulator.append((toc.sourceLocation, element.destination))
        }
      }
    })
    if forwardTocs.isEmpty {
      return
    }
    let destinations = Set(forwardTocs.map { $0.destination })
    for cartLocation in destinations {
      labelTypes[cartLocation] = .elseType
    }
  }

}
