import Foundation

/** Creates an RGBDS assembly statement representing the given bytes as a db string. */
public func statement(for asciiCodes: [UInt8], characterMap: [UInt8: String]) -> Statement {
  var operands: [String] = []
  var stringRepresentableBytes: [UInt8] = []

  // Accumulate ascii characters until the first non-string-representable byte is encountered, at which point the
  // string-representable characters are flushed to the accumulator and the non-representable byte is added as a hex
  // operand.
  for byte in asciiCodes {
    if (byte >= 32 && byte <= 126) || characterMap[byte] != nil {
      stringRepresentableBytes.append(byte)
    } else {
      if stringRepresentableBytes.count > 0 {
        operands.append(quoteCharacter + asciiString(for: stringRepresentableBytes, characterMap: characterMap) + quoteCharacter)
        stringRepresentableBytes.removeAll()
      }
      operands.append(RGBDS.asHexString(byte))
    }
  }
  if stringRepresentableBytes.count > 0 {
    operands.append(quoteCharacter + asciiString(for: stringRepresentableBytes, characterMap: characterMap) + quoteCharacter)
  }
  return Statement(opcode: dataOpcode, operands: operands)
}

/** Converts the given set of ascii codes directly to a string representation using the given character map. */
private func asciiString(for asciiCodes: [UInt8], characterMap: [UInt8: String]) -> String {
  return asciiCodes.map {
    if let string = characterMap[$0] {
      return string
    } else {
      return String(bytes: [$0], encoding: .ascii)!
    }
  }.joined()
}
