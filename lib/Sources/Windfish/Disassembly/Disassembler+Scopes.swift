import Foundation

extension Disassembler {
  /** Returns all scopes that intersect with the given location. */
  func contiguousScopes(at location: Cartridge.Location) -> Set<Range<Cartridge._Location>> {
    let effectiveBank: Cartridge.Bank = self.effectiveBank(at: location.address, in: location.bank)
    return contiguousScopes[effectiveBank, default: Set()].filter { (scope: (Range<Cartridge._Location>)) -> Bool in
      scope.contains(Cartridge._Location(truncatingIfNeeded: location.index))
    }
  }

  /** Returns all labeled scopes that intersect with the given location. */
  public func labeledContiguousScopes(at location: Cartridge.Location) -> [(label: String, scope: Range<Cartridge._Location>)] {
    return contiguousScopes(at: location).compactMap { (range: Range<Cartridge._Location>) -> (label: String, scope: Range<Cartridge._Location>)? in
      let addressAndBank: (address: LR35902.Address, bank: Cartridge.Bank) = Cartridge.addressAndBank(from: range.lowerBound)
      guard let label: String = label(at: addressAndBank.address, in: addressAndBank.bank) else {
        return nil
      }
      return (label, range)
    }
  }

  /** Registers a new contiguous scope at the given range. */
  func registerContiguousScope(range: Range<Cartridge.Location>) {
    contiguousScopes[range.lowerBound.bank, default: Set()]
      .insert(Cartridge._Location(truncatingIfNeeded: range.lowerBound.index)..<Cartridge._Location(truncatingIfNeeded: range.upperBound.index))
  }
}
