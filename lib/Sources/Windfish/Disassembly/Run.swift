import Foundation
import CPU

enum InstructionCategory {
  case call
  case ret
}

protocol InstructionSpecDisassemblyInfo {
  /**
   The category this instruction's opcode falls under, if any.
   */
  var category: InstructionCategory? { get }
}

final class RunGroup: Sequence {
  init(runs: [Disassembler.Run]) {
    self.runs = runs
  }

  fileprivate let runs: [Disassembler.Run]

  func makeIterator() -> IndexingIterator<[Disassembler.Run]> {
    return runs.makeIterator()
  }

  var first: Disassembler.Run? {
    return runs.first
  }

  /**
   The run group's starting address.
   */
  lazy var startLocation: Cartridge.Location? = {
    guard let firstRun = runs.first else {
      return nil
    }
    return firstRun.startLocation
  }()

  /**
   Returns all of the ranges visited by the runs in this group.

   - Note: Runs are not an ideal representation of the call graph because runs intentionally do not recurse on
   themselves. A more ideal representation for scope calculation would be a legitimiate call graph that annotates, for
   a given instruction, all of the reachable transfers of control. This graph could then reasonably be walked each time
   we want to calculate scope.
   */
  lazy var scope: IndexSet = {
    return runs.compactMap { $0.visitedRange }.reduce(into: IndexSet()) { (accumulator, visitedRange) in
      accumulator.insert(integersIn: visitedRange.asIntRange())
    }
  }()

  lazy var firstContiguousScopeRange: Range<Cartridge.Location>? = {
    guard let startLocation = startLocation else {
      return nil
    }
    if let range = scope.rangeView.first(where: { $0.lowerBound == startLocation.index }) {
      return Cartridge.Location(index: range.lowerBound)..<Cartridge.Location(index: range.upperBound)
    }
    if let range = scope.rangeView.first(where: { $0.contains(startLocation.index) }) {
      return startLocation..<Cartridge.Location(index: range.upperBound)
    }
    return nil
  }()
}

extension Disassembler.Run {
  /**
   Breaks this run apart into call groups.

   - Returns: a collection of arrays of Runs, where each array of Runs is part of a single call invocation.
   */
  func runGroups() -> [RunGroup] {
    var runGroups: [RunGroup] = []

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

      runGroups.append(RunGroup(runs: runGroup))
    }

    assert(sanityCheckSeenRuns == (runGroups.reduce(0) { $0 + $1.runs.count }))

    return runGroups
  }
}
