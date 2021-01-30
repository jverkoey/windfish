import Foundation

extension Disassembler.Configuration {
  func allMappedCharacters() -> [UInt8: String] {
    return characterMap
  }

  /** Maps a character to a specific string. */
  func mapCharacter(_ character: UInt8, to string: String) {
    characterMap[character] = string
  }
}
