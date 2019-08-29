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

        simulate(range: visitedRange) { instruction, location, state in
          switch instruction.spec {
          case .ld(.ffimm8addr, let numeric) where registers8.contains(numeric):
            let address = 0xFF00 | LR35902.Address(instruction.imm8!)
            if let global = self.globals[address],
              let dataType = global.dataType,
              let sourceLocation = state.a?.sourceLocation {
              self.typeAtLocation[sourceLocation] = dataType
            }

          case .cp(_):
            if case .variable(let address) = state.a?.value,
              let global = self.globals[address],
              let dataType = global.dataType {
              self.typeAtLocation[location] = dataType
            }

          case .ld(.ffimm8addr, let numeric) where registers8.contains(numeric):
            let address = 0xFF00 | LR35902.Address(instruction.imm8!)
            if let global = self.globals[address],
              let dataType = global.dataType,
              let sourceLocation = state.a?.sourceLocation {
              self.typeAtLocation[sourceLocation] = dataType
            }

          case .and(.imm8):
            if case .variable(let address) = state.a?.value,
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
      guard let runStartAddress = runGroup.startAddress,
        let runGroupLabel = labels[runStartAddress],
        let runGroupName = runGroupLabel.components(separatedBy: ".").first else {
        continue
      }

      // Expand scopes for the label.
      // TODO: This doesn't work well if the labels change after the scope has been defined.
      // TODO: Labels should be annotable with a name and a scope independently.
      let scope = runGroup.scope
      if scope.isEmpty {
        continue
      }
      expandScope(forLabel: runGroupName, scope: scope)

      // Define the initial contiguous scope for the rungroup's label.
      // This allows functions to rewrite local labels as relative labels.
      guard let contiguousScope = runGroup.firstContiguousScopeRange else {
        continue
      }
      addContiguousScope(range: contiguousScope)

      let labelLocations = self.labelLocations(in: contiguousScope.dropFirst())

      rewriteLoopLabels(in: contiguousScope.dropFirst())
      rewriteElseLabels(in: contiguousScope.dropFirst())
      rewriteReturnLabels(at: labelLocations)
    }
  }

  private func rewriteReturnLabels(at locations: [LR35902.CartridgeLocation]) {
    let returnLabelAddresses = locations.filter { instructionMap[$0]?.spec.category == .ret }
    for cartLocation in returnLabelAddresses {
      let addressAndBank = LR35902.addressAndBank(from: cartLocation)
      labels[cartLocation] = "return_\(addressAndBank.address.hexString)_\(addressAndBank.bank.hexString)"
    }
  }

  private func rewriteLoopLabels(in scope: Range<LR35902.CartridgeLocation>) {
    let tocs: [(destination: LR35902.CartridgeLocation, tocs: Set<TransferOfControl>)] = scope.compactMap {
      let (address, bank) = LR35902.addressAndBank(from: $0)
      if let toc = transfersOfControl(at: address, in: bank) {
        return ($0, toc)
      } else {
        return nil
      }
    }
    let backwardTocs: [(source: LR35902.CartridgeLocation, destination: LR35902.CartridgeLocation)] = tocs.reduce(into: [], { (accumulator, element) in
      let tocsInThisScope = element.tocs.filter {
        scope.contains($0.sourceLocation) && element.destination < $0.sourceLocation && labels[element.destination] != nil
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
      let addressAndBank = LR35902.addressAndBank(from: cartLocation)
      labels[cartLocation] = "loop_\(addressAndBank.address.hexString)_\(addressAndBank.bank.hexString)"
    }
  }

  private func rewriteElseLabels(in scope: Range<LR35902.CartridgeLocation>) {
    let tocs: [(destination: LR35902.CartridgeLocation, tocs: Set<TransferOfControl>)] = scope.compactMap {
      let (address, bank) = LR35902.addressAndBank(from: $0)
      if let toc = transfersOfControl(at: address, in: bank) {
        return ($0, toc)
      } else {
        return nil
      }
    }
    let forwardTocs: [(source: LR35902.CartridgeLocation, destination: LR35902.CartridgeLocation)] = tocs.reduce(into: [], { (accumulator, element) in
      let tocsInThisScope = element.tocs.filter {
        scope.contains($0.sourceLocation) && element.destination > $0.sourceLocation && labels[element.destination] != nil
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
      let addressAndBank = LR35902.addressAndBank(from: cartLocation)
      labels[cartLocation] = "else_\(addressAndBank.address.hexString)_\(addressAndBank.bank.hexString)"
    }
  }

}
