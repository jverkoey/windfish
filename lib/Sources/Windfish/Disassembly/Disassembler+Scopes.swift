import Foundation

extension Disassembler.BankRouter {
  /** Returns the label at the given location, if any. */
  public func labeledContiguousScopes(at location: Cartridge.Location) -> [(label: String, scope: Range<Cartridge.Location>)] {
    return bankWorkers[Int(truncatingIfNeeded: location.bankIndex)].labeledContiguousScopes(at: location)
  }
}

extension Disassembler.BankWorker {
  /** Returns all scopes that intersect with the given location. */
  func contiguousScopes(at location: Cartridge.Location) -> Set<Range<Cartridge.Location>> {
    assert(location.bankIndex == bank)
    return contiguousScopes.filter { (scope: (Range<Cartridge.Location>)) -> Bool in
      scope.contains(location)
    }
  }

  /** Returns all labeled scopes that intersect with the given location. */
  func labeledContiguousScopes(at location: Cartridge.Location) -> [(label: String, scope: Range<Cartridge.Location>)] {
    assert(location.bankIndex == bank)
    return contiguousScopes(at: location).compactMap { (range: Range<Cartridge.Location>) -> (label: String, scope: Range<Cartridge.Location>)? in
      guard let label: String = label(at: range.lowerBound) else {
        return nil
      }
      return (label, range)
    }
  }

  /** Registers a new contiguous scope at the given range. */
  func registerContiguousScope(range: Range<Cartridge.Location>) {
    assert(range.lowerBound.bankIndex == bank)
    contiguousScopes.insert(range)
  }
}
