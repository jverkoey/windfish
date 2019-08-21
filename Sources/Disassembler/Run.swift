import Foundation
import CPU

public final class Run<TAddress: BinaryInteger, TInstruction: Instruction> {
  let startAddress: TAddress
  let endAddress: TAddress?

  public init(from startAddress: TAddress, upTo endAddress: TAddress? = nil) {
    self.startAddress = startAddress
    self.endAddress = endAddress
  }

  var visitedRange: Range<TAddress>?

  var children: [Run] = []

  var invocationInstruction: TInstruction?
  var invocationAddress: TAddress?

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
