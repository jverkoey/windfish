import Foundation
import CPU

public protocol Run {
  associatedtype InstructionT: Instruction

  var invocationInstruction: InstructionT? { get }

  /**
   Runs that were invoked within this run via a control transfer.
   */
  var children: [Self] { get }
}

extension Run {
  /**
   Breaks this run apart into call groups.

   - Returns: a collection of arrays of Runs, where each array of Runs is part of a single call invocation.
   */
  public func runGroups() -> [[Self]] {
    var runGroups: [[Self]] = []

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
