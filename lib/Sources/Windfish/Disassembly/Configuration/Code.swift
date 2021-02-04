import Foundation

extension Disassembler.MutableConfiguration {
  func allPotentialCode() -> Set<Range<Cartridge.Location>> {
    return executableRegions
  }

  /** Registers a block of code at the given range. */
  public func registerPotentialCode(at range: Range<Cartridge.Location>, named name: String? = nil) {
    guard !range.isEmpty else {
      return
    }
    if let name = name {
      registerLabel(at: range.lowerBound, named: name)
    }

    executableRegions.insert(range)
  }

  /** Registers a function at the given location. */
  public func registerFunction(startingAt location: Cartridge.Location, named name: String) {
    let upperBound: LR35902.Address = (location.address < 0x4000) ? 0x4000 : 0x8000
    registerPotentialCode(at: location..<Cartridge.Location(address: upperBound, bank: location.bank), named: name)
  }
}
