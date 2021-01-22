import Foundation

extension Disassembler {
  /** Returns all scopes that intersect with the given location. */
  func contiguousScopes(at location: Cartridge.Location) -> Set<Range<Cartridge.Location>> {
    return contiguousScopes[location.bank, default: Set()].filter { (scope: (Range<Cartridge.Location>)) -> Bool in
      scope.contains(location)
    }
  }

  /** Returns all labeled scopes that intersect with the given location. */
  public func labeledContiguousScopes(at location: Cartridge.Location) -> [(label: String, scope: Range<Cartridge.Location>)] {
    return contiguousScopes(at: location).compactMap { (range: Range<Cartridge.Location>) -> (label: String, scope: Range<Cartridge.Location>)? in
      guard let label: String = label(at: range.lowerBound.address, in: range.lowerBound.bank) else {
        return nil
      }
      return (label, range)
    }
  }

  /** Registers a new contiguous scope at the given range. */
  func registerContiguousScope(range: Range<Cartridge.Location>) {
    contiguousScopes[range.lowerBound.bank, default: Set()].insert(range)
  }
}
