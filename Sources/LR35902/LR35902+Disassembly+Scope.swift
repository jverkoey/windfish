import Foundation

extension LR35902.Disassembly {

  func rewriteScopes(_ run: LR35902.Disassembly.Run) {
    // Compute scope and rewrite function labels if we're a function.

    for runGroup in run.runGroups() {
      guard let firstRun = runGroup.first else {
        continue
      }

      let scope = runGroup.scope()
      if scope.isEmpty {
        continue
      }

      let runStartAddress = firstRun.startAddress
      guard let runGroupName = labels[runStartAddress] else {
        continue
      }
      expandScope(forLabel: runGroupName, scope: scope)

      // Get the first contiguous block of scope.
      guard let contiguousScope = scope.rangeView.first(where: { $0.lowerBound == runStartAddress }) else {
        continue
      }
      for address in contiguousScope {
        contiguousScopes[LR35902.CartridgeAddress(address)] = runGroupName
      }

      var firstReturnIndex: LR35902.CartridgeAddress? = nil

      contiguousScope.dropFirst().forEach {
        let index = LR35902.CartridgeAddress($0)
        guard labels[index] != nil else {
          return
        }
        if case .ret = instructionMap[index]?.spec {
          if let firstReturnIndex = firstReturnIndex {
            labels[index] = "\(runGroupName).return_\(LR35902.Address(index % LR35902.bankSize).hexString)"
            labels[firstReturnIndex] = "\(runGroupName).return_\(LR35902.Address(firstReturnIndex % LR35902.bankSize).hexString)"
          } else {
            labels[index] = "\(runGroupName).return"
            firstReturnIndex = index
          }
        } else {
          let bank = LR35902.Bank(index / LR35902.bankSize)
          let address = index % LR35902.bankSize + LR35902.CartridgeAddress((bank > 0) ? 0x4000 : 0x0000)
          labels[index] = "\(runGroupName).fn_\(bank.hexString)_\(LR35902.Address(address).hexString)"
        }
      }
    }
  }

}
