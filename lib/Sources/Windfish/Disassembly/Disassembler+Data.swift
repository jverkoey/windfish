import Foundation

extension Disassembler {
  public enum DataFormat {
    case bytes
    case image1bpp
    case image2bpp
  }

  /** Returns the format of the data at the given location, if any is known. */
  func formatOfData(at address: LR35902.Address, in bank: Cartridge.Bank) -> DataFormat? {
    precondition(bank > 0)
    guard let location = Cartridge.location(for: address, in: bank) else {
      return nil
    }
    let intLocation = Int(truncatingIfNeeded: location)
    return dataFormats.first { (key: DataFormat, value: IndexSet) -> Bool in
      value.contains(intLocation)
    }?.key
  }

  /** Registers that a specific location contains data. */
  func registerData(at address: LR35902.Address, in bank: Cartridge.Bank) {
    precondition(bank > 0)
    registerData(at: address..<(address+1), in: bank)
  }

  /** Registers that a specific range contains data. */
  public func registerData(at range: Range<LR35902.Address>, in bank: Cartridge.Bank, format: DataFormat = .bytes) {
    precondition(bank > 0)
    guard let cartRange: Range<Cartridge.Location> = range.asCartridgeRange(in: bank) else {
      return
    }
    let intRange = cartRange.asIntRange()
    for key in dataFormats.keys {
      dataFormats[key]?.remove(integersIn: intRange)
    }
    dataFormats[format, default: IndexSet()].insert(integersIn: intRange)
    registerRegion(range: cartRange.asIntRange(), as: .data)
  }
}
