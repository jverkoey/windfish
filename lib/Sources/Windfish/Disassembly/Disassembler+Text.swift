import Foundation

extension Disassembler {
  /** Returns the maximum length of a line of text at the given location, if known. */
  func lineLengthOfText(at address: LR35902.Address, in bank: Cartridge.Bank) -> Int? {
    precondition(bank > 0)
    guard let location: Cartridge.Location = Cartridge.location(for: address, in: bank) else {
      return nil
    }
    return textLengths.first { (key: Range<Cartridge.Location>, value: Int) -> Bool in
      key.contains(location)
    }?.value
  }

  /** Registers that a specific location contains text. */
  public func registerText(at range: Range<LR35902.Address>, in bank: Cartridge.Bank, lineLength: Int? = nil) {
    precondition(bank > 0)
    guard let cartRange = range.asCartridgeRange(in: bank) else {
      return
    }
    let range: Range<Int> = cartRange.asIntRange()
    if let lineLength = lineLength {
      textLengths[cartRange] = lineLength
    }
    registerRegion(range: range, as: .text)
  }
}
