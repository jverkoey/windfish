import Foundation

import LR35902
import Tracing

extension Project {
  final class Region: NSObject {
    struct Kind {
      static let region = "Region"
      static let label = "Label"
      static let function = "Function"
      static let string = "String"
      static let data = "Data"
      static let image1bpp = "Image (1bpp)"
      static let image2bpp = "Image (2bpp)"
    }
    var regionType: String {
      didSet {
        if regionType == Kind.label || regionType == Kind.function {
          length = 0
        }
      }
    }
    var name: String
    var bank: Cartridge.Bank
    var address: LR35902.Address
    var length: LR35902.Address

    init(regionType: String, name: String, bank: Cartridge.Bank, address: LR35902.Address, length: LR35902.Address) {
      self.regionType = regionType
      self.name = name
      self.bank = bank
      self.address = address
      self.length = length
    }
  }

  static func loadRegions(from url: URL) -> [Region] {
    guard let regionsText = try? String(contentsOf: url, encoding: .utf8) else {
      return []
    }
    var regions: [Region] = []
    regionsText.enumerateLines { line, _ in
      if line.isEmpty {
        return
      }
      let codeAndComments = line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
      let code = codeAndComments[0].trimmed()
      if !code.hasSuffix(":") {
        return
      }
      let name = String(code.dropLast())
      let comments = codeAndComments[1].trimmed()
      let scanner = Scanner(string: comments)
      _ = scanner.scanUpToString("[")
      _ = scanner.scanString("[")
      let regionType = scanner.scanUpToString("]")!.trimmed()
      _ = scanner.scanUpToString("$")
      _ = scanner.scanString("$")
      let bank = scanner.scanUpToString(":")!.trimmed()
      _ = scanner.scanUpToString("$")
      _ = scanner.scanString("$")
      let address = scanner.scanUpToString("[")!.trimmed()
      _ = scanner.scanString("[")
      let length = scanner.scanUpToString("]")!.trimmed()
      regions.append(Region(regionType: regionType,
                            name: name,
                            bank: Cartridge.Bank(bank, radix: 16)!,
                            address: LR35902.Address(address, radix: 16)!,
                            length: LR35902.Address(length)!))
    }
    return regions
  }
}
