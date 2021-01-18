import Foundation
import CPU

public enum InstructionCategory {
  case call
  case ret
}

public protocol InstructionSpecDisassemblyInfo {
  /**
   The category this instruction's opcode falls under, if any.
   */
  var category: InstructionCategory? { get }
}

public final class RunGroup: Sequence {
  init(runs: [Disassembler.Run]) {
    self.runs = runs
  }

  fileprivate let runs: [Disassembler.Run]

  public func makeIterator() -> IndexingIterator<[Disassembler.Run]> {
    return runs.makeIterator()
  }

  public var first: Disassembler.Run? {
    return runs.first
  }

  /**
   The run group's starting address.
   */
  public lazy var startAddress: Cartridge.Location? = {
    guard let firstRun = runs.first else {
      return nil
    }
    return firstRun.startAddress
  }()

  /**
   Returns all of the ranges visited by the runs in this group.

   - Note: Runs are not an ideal representation of the call graph because runs intentionally do not recurse on
   themselves. A more ideal representation for scope calculation would be a legitimiate call graph that annotates, for
   a given instruction, all of the reachable transfers of control. This graph could then reasonably be walked each time
   we want to calculate scope.
   */
  public lazy var scope: IndexSet = {
    return runs.compactMap { $0.visitedRange }.reduce(into: IndexSet()) { (accumulator, visitedRange) in
      accumulator.insert(integersIn: Int(visitedRange.lowerBound)..<Int(visitedRange.upperBound))
    }
  }()

  public lazy var firstContiguousScopeRange: Range<Cartridge.Location>? = {
    if let startAddress = startAddress {
      if let range = scope.rangeView.first(where: { $0.lowerBound == Int(startAddress) }) {
        return Range<Cartridge.Location>(uncheckedBounds: (Cartridge.Location(range.lowerBound),
                                                                   Cartridge.Location(range.upperBound)))
      } else if let range = scope.rangeView.first(where: { $0.contains(Int(startAddress)) }) {
        return Range<Cartridge.Location>(uncheckedBounds: (startAddress, Cartridge.Location(range.upperBound)))
      }
    }
    return nil
  }()
}

extension Disassembler.Run {
  /**
   Breaks this run apart into call groups.

   - Returns: a collection of arrays of Runs, where each array of Runs is part of a single call invocation.
   */
  public func runGroups() -> [RunGroup] {
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
