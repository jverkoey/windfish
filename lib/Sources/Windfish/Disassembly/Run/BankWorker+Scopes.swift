import Foundation

extension Disassembler.BankRouter {
  /** Returns the label at the given location, if any. */
  public func labeledContiguousScopes(at location: Cartridge.Location) -> [String] {
    return bankWorkers[Int(truncatingIfNeeded: location.bankIndex)].labeledContiguousScopes(at: location)
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
  func labeledContiguousScopes(at location: Cartridge.Location) -> [String] {
    assert(location.bankIndex == bank)
    assert(_contiguousScopes.isEmpty || !contiguousScopes.isEmpty)
    guard let scopeStarts: Set<Cartridge.Location> = contiguousScopes[location] else {
      return []
    }
    return scopeStarts.compactMap { (scopeStart: Cartridge.Location) -> String? in
      guard let label: String = label(at: scopeStart) else {
        return nil
      }
      return label
    }
  }

  /** Registers a new contiguous scope at the given range. */
  func registerContiguousScope(range: Range<Cartridge.Location>) {
    assert(range.lowerBound.bankIndex == bank)
    _contiguousScopes.insert(range)
  }
}
