import Foundation
import RGBDS

extension Disassembler {
  func createCharacterMapSource() -> Source.FileDescription? {
    let characterMap = configuration.allMappedCharacters()
    guard !characterMap.isEmpty else {
      return nil
    }

    let asm = characterMap.sorted { $0.key < $1.key }.map { (mappedByte: UInt8, string: String) in
      "charmap \"\(string)\", \(RGBDS.asHexString(mappedByte))"
    }.joined(separator: "\n")

    return .charmap(content: asm)
  }
}
