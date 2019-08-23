import Foundation

extension LR35902.Disassembly {
  func rewriteScopes(_ run: LR35902.Disassembly.Run) {
    // Compute scope and rewrite function labels if we're a function.

    for runGroup in run.runGroups() {
      guard let runStartAddress = runGroup.startAddress,
        let runGroupName = labels[runStartAddress] else {
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
      setContiguousScope(forLabel: runGroupName, range: contiguousScope)

      let labelLocations = self.labelLocations(in: contiguousScope.dropFirst())

      rewriteLabels(at: labelLocations, with: runGroupName)
      rewriteLoopLabels(in: contiguousScope.dropFirst(), with: runGroupName)
      rewriteElseLabels(in: contiguousScope.dropFirst(), with: runGroupName)
      rewriteReturnLabels(at: labelLocations, with: runGroupName)
    }
  }

  private func rewriteLabels(at locations: [LR35902.CartridgeLocation], with scope: String) {
    for cartLocation in locations {
      let addressAndBank = LR35902.addressAndBank(from: cartLocation)
      labels[cartLocation] = "\(scope).fn_\(addressAndBank.bank.hexString)_\(addressAndBank.address.hexString)"
    }
  }

  private func rewriteReturnLabels(at locations: [LR35902.CartridgeLocation], with scope: String) {
    let returnLabelAddresses = locations.filter { instructionMap[$0]?.spec.category == .ret }
    let hasManyReturns = returnLabelAddresses.count > 1
    for cartLocation in returnLabelAddresses {
      if hasManyReturns {
        labels[cartLocation] = "\(scope).return_\(LR35902.addressAndBank(from: cartLocation).address.hexString)"
      } else {
        labels[cartLocation] = "\(scope).return"
      }
    }
  }

  private func rewriteLoopLabels(in scope: Range<LR35902.CartridgeLocation>, with scopeName: String) {
    guard !scopeName.contains(".") else {
      return
    }

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
    let hasManyDestinations = destinations.count > 1
    for cartLocation in destinations {
      if hasManyDestinations {
        labels[cartLocation] = "\(scopeName).loop_\(LR35902.addressAndBank(from: cartLocation).address.hexString)"
      } else {
        labels[cartLocation] = "\(scopeName).loop"
      }
    }
  }

  private func rewriteElseLabels(in scope: Range<LR35902.CartridgeLocation>, with scopeName: String) {
    guard !scopeName.contains(".") else {
      return
    }

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
    let hasManyDestinations = destinations.count > 1
    for cartLocation in destinations {
      if hasManyDestinations {
        labels[cartLocation] = "\(scopeName).else_\(LR35902.addressAndBank(from: cartLocation).address.hexString)"
      } else {
        labels[cartLocation] = "\(scopeName).else"
      }
    }
  }

}
