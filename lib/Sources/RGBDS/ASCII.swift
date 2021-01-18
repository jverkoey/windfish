import Foundation

/** Converts the given set of ascii codes directly to a string representation using the given character map. */
private func asciiString(for asciiCodes: ContiguousArray<UInt8>, characterMap: [UInt8: String]) -> String {
  return asciiCodes.map { (code: UInt8) -> String in
    return characterMap[code] ?? String(bytes: [code], encoding: .ascii)!
  }.joined()
}

extension Statement {
  /** Creates an RGBDS assembly statement representing the given bytes as a db-compatible string. */
  public init(withAscii asciiCodes: [UInt8], characterMap: [UInt8: String]) {
    var operands: [String] = []
    var buffer = ContiguousArray<UInt8>()

    // Accumulate ascii characters until the first non-string-representable byte is encountered, at which point the
    // string-representable characters are flushed to the accumulator and the non-representable byte is added as a hex
    // operand.
    for byte in asciiCodes {
      // Is the byte representable in ASCII, or does the byte otherwise have a string representation?
      if (byte >= 32 && byte <= 126) || characterMap[byte] != nil {
        buffer.append(byte)
        continue
      }
      if !buffer.isEmpty {
        operands.append(quoteCharacter + asciiString(for: buffer, characterMap: characterMap) + quoteCharacter)
        buffer.removeAll(keepingCapacity: true)
      }
      operands.append(RGBDS.asHexString(byte))
    }
    if !buffer.isEmpty {
      operands.append(quoteCharacter + asciiString(for: buffer, characterMap: characterMap) + quoteCharacter)
    }
    self.init(opcode: dataOpcode, operands: operands)
  }
}
