import Foundation

extension Disassembler {
  /** Returns the maximum length of a line of text at the given location, if known. */
  func lineLengthOfText(at location: Cartridge.Location) -> Int? {
    return textLengths.first { (key: Range<Cartridge._Location>, value: Int) -> Bool in
      key.contains(Cartridge._Location(truncatingIfNeeded: location.index))
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

  /** Maps a character to a specific string. */
  func mapCharacter(_ character: UInt8, to string: String) {
    characterMap[character] = string
  }
}
