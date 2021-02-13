import Foundation

import LR35902
import RGBDS

extension Project {
  final class Global: NSObject {
    init(name: String, address: LR35902.Address, dataType: String) {
      self.name = name
      self.address = address
      self.dataType = dataType
    }

    var name: String
    var address: LR35902.Address
    var dataType: String
  }

  static func loadGlobals(from url: URL) -> [Global] {
    guard let globalText = try? String(contentsOf: url, encoding: .utf8) else {
      return []
    }
    var globals: [Global] = []
    globalText.enumerateLines { line, _ in
      guard !line.isEmpty else {
        return
      }
      let codeAndComments: [String.SubSequence] = line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
      let code: String.SubSequence = codeAndComments[0]
      guard code.contains(" EQU ") else {
        return
      }
      let definitionParts: [String] = code.components(separatedBy: " EQU ")
      let name: String = definitionParts[0].trimmed()
      let addressText: String = definitionParts[1].trimmed()
      guard addressText.starts(with: RGBDS.NumericPrefix.hexadecimal),
            let address: LR35902.Address = LR35902.Address(addressText.dropFirst(), radix: 16) else {
        return
      }
      let comments: String = codeAndComments[1].trimmed()
      let scanner: Scanner = Scanner(string: comments)
      _ = scanner.scanUpToString("[")
      _ = scanner.scanString("[")
      let dataType = scanner.scanUpToString("]")!.trimmed()
      globals.append(Global(name: name, address: address, dataType: dataType))
    }
    return globals
  }
}
