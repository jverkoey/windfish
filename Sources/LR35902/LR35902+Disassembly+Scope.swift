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
      for address in contiguousScope {
        contiguousScopes[LR35902.CartridgeLocation(address)] = runGroupName
      }

      // Rewrite local labels within the function's first contiguous block of scope.
      let labelAddresses = self.labelAddresses(in: contiguousScope.dropFirst())
      for cartLocation in labelAddresses {
        let addressAndBank = LR35902.addressAndBank(from: cartLocation)
        labels[cartLocation] = "\(runGroupName).fn_\(addressAndBank.bank.hexString)_\(addressAndBank.address.hexString)"
      }

      // Rewrite return labels within the function's first contiguous block of scope.
      let returnLabelAddresses = labelAddresses.filter { instructionMap[$0]?.spec.category == .ret }
      let hasManyReturns = returnLabelAddresses.count > 1
      for cartLocation in returnLabelAddresses {
        if hasManyReturns {
          labels[cartLocation] = "\(runGroupName).return_\(LR35902.addressAndBank(from: cartLocation).address.hexString)"
        } else {
          labels[cartLocation] = "\(runGroupName).return"
        }
      }
    }
  }
}
