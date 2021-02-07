import Foundation

import LR35902
import RGBDS

extension Disassembler {
  func createVariablesSource() -> Source.FileDescription? {
    let globals: [LR35902.Address: MutableConfiguration.Global] = configuration.allGlobals()
    guard !globals.isEmpty else {
      return nil
    }

    let asm = globals.filter { $0.key >= 0x8000 }.sorted { $0.key < $1.key }.map { (key: LR35902.Address, value: MutableConfiguration.Global) in
      "\(value.name) EQU \(RGBDS.asHexString(key))"
    }.joined(separator: "\n\n")

    return .variables(content: asm)
  }
}
