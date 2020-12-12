import Foundation

/** Converts the given set of ascii codes to a string representation using the given character map. */
public func asciiString(for asciiCodes: [UInt8], characterMap: [UInt8: String]) -> String {
  return asciiCodes.map {
    if let string = characterMap[$0] {
      return string
    } else {
      return String(bytes: [$0], encoding: .ascii)!
    }
  }.joined()
}
