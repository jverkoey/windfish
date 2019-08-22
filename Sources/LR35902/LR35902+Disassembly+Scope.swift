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
}
