import Foundation

import Tracing

extension Disassembler.BankRouter {
  /** Returns the label at the given location, if any. */
  public func labeledContiguousScope(at location: Cartridge.Location) -> String? {
    return bankWorkers[Int(truncatingIfNeeded: location.bankIndex)].labeledContiguousScope(at: location)
  }
}

extension Disassembler.BankWorker {
  /** Returns all scopes that intersect with the given location. */
  func contiguousScopes(at location: Cartridge.Location) -> Set<Cartridge.Location> {
    assert(location.bankIndex == bank)
    assert(_contiguousScopes.isEmpty || !contiguousScopes.isEmpty)
    return contiguousScopes[location] ?? Set()
  }

  /** Returns all labeled scopes that intersect with the given location. */
  func labeledContiguousScope(at location: Cartridge.Location) -> String? {
    assert(location.bankIndex == bank)
    assert(_contiguousScopes.isEmpty || !contiguousScopes.isEmpty)
    guard let scopeStarts: Set<Cartridge.Location> = contiguousScopes[location],
          let firstScopeLocation: Cartridge.Location = scopeStarts.sorted().first else {
      return nil
    }
    return label(at: firstScopeLocation)
  }

  /** Registers a new contiguous scope at the given range. */
  func registerContiguousScope(range: Range<Cartridge.Location>) {
    assert(range.lowerBound.bankIndex == bank)
    _contiguousScopes.insert(range)
  }
}
