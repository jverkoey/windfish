import Foundation
import RGBDS

extension Disassembler {
  func createVariablesSource() -> Source.FileDescription? {
    let globals: [LR35902.Address: Configuration.Global] = configuration.allGlobals()
    guard !globals.isEmpty else {
      return nil
    }

    let asm = globals.filter { $0.key >= 0x8000 }.sorted { $0.key < $1.key }.map { (key: LR35902.Address, value: Configuration.Global) in
      "\(value.name) EQU \(RGBDS.asHexString(key))"
    }.joined(separator: "\n\n")

    return .variables(content: asm)
  }
}
