import Foundation

extension Disassembler.MutableConfiguration {
  func allPotentialText() -> Set<Range<Cartridge.Location>> {
    return potentialText
  }
  
  /** Returns the maximum length of a line of text at the given location, if known. */
  func lineLengthOfText(at location: Cartridge.Location) -> Int? {
    return textLengths.first { (key: Range<Cartridge.Location>, value: Int) -> Bool in
      key.contains(location)
    }?.value
  }

  /** Registers that a specific location contains text. */
  public func registerText(at range: Range<Cartridge.Location>, lineLength: Int? = nil) {
    if let lineLength: Int = lineLength {
      textLengths[range] = lineLength
    }
    potentialText.insert(range)
  }
}
