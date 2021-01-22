import Foundation

extension Disassembler {

  /** Registers a function at the given location. */
  public func registerExecutableRegion(at range: Range<LR35902.Address>, in bank: Cartridge.Bank, named name: String? = nil) {
    guard !range.isEmpty else {
      return
    }
    precondition(bank > 0)
    if let name = name {
      registerLabel(at: Cartridge.Location(address: range.lowerBound, bank: bank), named: name)
    }

    guard let startLocation = Cartridge.location(for: range.lowerBound, in: bank),
          let endLocation = Cartridge.location(for: range.upperBound - 1, in: bank) else {
      return
    }
    executableRegions.insert(startLocation..<(endLocation + 1))
  }

  /** Registers a function at the given location. */
  public func registerFunction(startingAt pc: LR35902.Address, in bank: Cartridge.Bank, named name: String) {
    let upperBound: LR35902.Address = (pc < 0x4000) ? 0x4000 : 0x8000
    registerExecutableRegion(at: pc..<upperBound, in: bank, named: name)
  }
}
