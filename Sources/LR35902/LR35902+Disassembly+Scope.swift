import Foundation

extension LR35902.Disassembly {

  func rewriteScopes(_ run: LR35902.Disassembly.Run) {
    // Compute scope and rewrite function labels if we're a function.

    for runGroup in run.runGroups() {
      // Calculate scope.
      var runScope = IndexSet()
      runGroup.forEach { run in
        if let visitedRange = run.visitedRange {
          runScope.insert(integersIn: Int(visitedRange.lowerBound)..<Int(visitedRange.upperBound))
        }
      }

      // Nothing to do for empty runs.
      if runScope.isEmpty {
        continue
      }

      // If the scope has a name, then map the scope and labels to that name.
      let entryRun = runGroup.first!
      let runStartAddress = entryRun.cartStartAddress
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
