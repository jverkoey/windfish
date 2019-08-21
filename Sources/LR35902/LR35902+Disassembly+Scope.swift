import Foundation

extension LR35902.Disassembly {

  func rewriteScopes(_ run: LR35902.Disassembly.Run) {
    // Compute scope and rewrite function labels if we're a function.

    for runGroup in run.runGroups() {
      guard let firstRun = runGroup.first else {
        continue
      }

      let runScope = runGroup.scope()
      if runScope.isEmpty {
        continue
      }

      let runStartAddress = firstRun.startAddress
      if let runGroupName = labels[runStartAddress] {
        scopes[runGroupName, default: IndexSet()].formUnion(runScope)

        // Get the first contiguous block of scope.
        if let runScope = runScope.rangeView.first(where: { $0.lowerBound == runStartAddress }) {
          for address in runScope {
            contiguousScopes[LR35902.CartridgeAddress(address)] = runGroupName
          }

          var firstReturnIndex: LR35902.CartridgeAddress? = nil

          runScope.dropFirst().forEach {
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
  }

}
