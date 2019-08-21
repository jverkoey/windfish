import Foundation
import CPU

public protocol Run {
  associatedtype AddressT: BinaryInteger
  associatedtype InstructionT: Instruction

  var visitedRange: Range<AddressT>? { get }

  var invocationInstruction: InstructionT? { get }

  /**
   Runs that were invoked within this run via a control transfer.
   */
  var children: [Self] { get }
}

public struct RunGroup<T: Run> {
  init(runs: [T]) {
    self.runs = runs
  }

  fileprivate let runs: [T]

  public var first: T? {
    return runs.first
  }

  /**
   Returns a composite index set of the ranges visited by the runs in this group.
   */
  public func scope() -> IndexSet {
    var scope = IndexSet()
    runs.forEach { run in
      if let visitedRange = run.visitedRange {
        scope.insert(integersIn: Int(visitedRange.lowerBound)..<Int(visitedRange.upperBound))
      }
    }
    return scope
  }
}

extension Run {
  /**
   Breaks this run apart into call groups.

   - Returns: a collection of arrays of Runs, where each array of Runs is part of a single call invocation.
   */
  public func runGroups() -> [RunGroup<Self>] {
    var runGroups: [RunGroup<Self>] = []

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

      runGroups.append(RunGroup<Self>(runs: runGroup))
    }

    assert(sanityCheckSeenRuns == (runGroups.reduce(0) { $0 + $1.runs.count }))

    return runGroups
  }
}
