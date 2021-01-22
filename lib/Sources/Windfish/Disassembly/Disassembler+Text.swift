import Foundation

extension Disassembler {
  /** Returns the maximum length of a line of text at the given location, if known. */
  func lineLengthOfText(at location: Cartridge.Location) -> Int? {
    return textLengths.first { (key: Range<Cartridge._Location>, value: Int) -> Bool in
      key.contains(Cartridge._Location(truncatingIfNeeded: location.index))
    }?.value
  }

  /** Registers that a specific location contains text. */
  public func registerText(at range: Range<Cartridge.Location>, lineLength: Int? = nil) {
    if let lineLength = lineLength {
      textLengths[Cartridge._Location(truncatingIfNeeded: range.lowerBound.index)..<Cartridge._Location(truncatingIfNeeded: range.upperBound.index)] = lineLength
    }
    registerRegion(range: range, as: .text)
  }

  /** Maps a character to a specific string. */
  func mapCharacter(_ character: UInt8, to string: String) {
    characterMap[character] = string
  }
}
