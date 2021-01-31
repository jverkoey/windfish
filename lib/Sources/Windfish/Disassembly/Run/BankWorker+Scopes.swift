import Foundation

extension Disassembler.BankRouter {
  /** Returns the label at the given location, if any. */
  public func labeledContiguousScopes(at location: Cartridge.Location) -> [(label: String, scope: Range<Cartridge.Location>)] {
    return bankWorkers[Int(truncatingIfNeeded: location.bankIndex)].labeledContiguousScopes(at: location)
  }
}

extension Disassembler.BankWorker {
  // TODO: Explore representing scopes as a dictionary of Address to scope start Address, which in turn can be used
  // to quickly look up the label name. The methods below are accounting for 1s worth of source generation time.

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
    var result: [(label: String, scope: Range<Cartridge.Location>)] = []
    for range: Range<Cartridge.Location> in contiguousScopes {
      guard range.contains(location) else {
        continue
      }
      guard let label: String = label(at: range.lowerBound) else {
        continue
      }
      result.append((label, range))
    }
    return result
  }

  /** Registers a new contiguous scope at the given range. */
  func registerContiguousScope(range: Range<Cartridge.Location>) {
    assert(range.lowerBound.bankIndex == bank)
    contiguousScopes.insert(range)
  }
}
