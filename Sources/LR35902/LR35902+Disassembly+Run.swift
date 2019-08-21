import Foundation

extension LR35902.Disassembly {
  class Run {
    let startAddress: LR35902.Address
    let endAddress: LR35902.Address?
    let bank: LR35902.Bank

    init(from startAddress: LR35902.Address, inBank bank: LR35902.Bank, upTo endAddress: LR35902.Address? = nil) {
      self.startAddress = startAddress
      self.endAddress = endAddress
      self.bank = bank
    }

    var visitedRange: Range<LR35902.CartridgeAddress>?

    var children: [Run] = []

    var invocationInstruction: LR35902.Instruction?
    var invocationAddress: LR35902.Address?

    func hasReachedEnd(with cpu: LR35902) -> Bool {
      if let endAddress = endAddress {
        return cpu.pc >= endAddress
      }
      return false
    }

    /**
     Breaks this run apart into logical call groups.
     */
    func runGroups() -> [[Run]] {
      var runGroups: [[Run]] = []

      var sanityCheckSeenRuns = 0

      var runGroupQueue = [self]
      while !runGroupQueue.isEmpty {
        let run = runGroupQueue.removeFirst()
        var runGroup = [run]

        sanityCheckSeenRuns += 1

        var descendantQueue = run.children
        while !descendantQueue.isEmpty {
          let descendant = descendantQueue.removeFirst()
          if case .call = descendant.invocationInstruction?.spec.category {
            // Calls mark the start of a new run group.
            runGroupQueue.append(descendant)
          } else {
            // Everything else is part of the current group...
            runGroup.append(descendant)
            // ...including any of its descendants.
            descendantQueue.append(contentsOf: descendant.children)

            sanityCheckSeenRuns += 1
          }
        }

        runGroups.append(runGroup)
      }

      assert(sanityCheckSeenRuns == (runGroups.reduce(0) { $0 + $1.count }))

      return runGroups
    }
  }
}
