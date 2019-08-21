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
      var firstReturnLocation: LR35902.CartridgeLocation? = nil
      contiguousScope.dropFirst().forEach {
        let cartLocation = LR35902.CartridgeLocation($0)
        guard labels[cartLocation] != nil else {
          return
        }
        if case .ret = instructionMap[cartLocation]?.spec {
          if let firstReturnIndex = firstReturnLocation {
            labels[cartLocation] = "\(runGroupName).return_\(LR35902.addressAndBank(from: cartLocation).address.hexString)"
            labels[firstReturnIndex] = "\(runGroupName).return_\(LR35902.addressAndBank(from: firstReturnIndex).address.hexString)"
          } else {
            labels[cartLocation] = "\(runGroupName).return"
            firstReturnLocation = cartLocation
          }
        } else {
          let bank = LR35902.Bank(cartLocation / LR35902.bankSize)
          let address = cartLocation % LR35902.bankSize + LR35902.CartridgeLocation((bank > 0) ? 0x4000 : 0x0000)
          labels[cartLocation] = "\(runGroupName).fn_\(bank.hexString)_\(LR35902.Address(address).hexString)"
        }
      }
    }
  }

}
