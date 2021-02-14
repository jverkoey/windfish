import Foundation

import LR35902
import RGBDS
import Tracing

extension Project {
  public final class Region: NSObject {
    public init(regionType: String, name: String, bank: Cartridge.Bank, address: LR35902.Address, length: LR35902.Address) {
      self.regionType = regionType
      self.name = name
      self.bank = bank
      self.address = address
      self.length = length
    }

    public struct Kind {
      public static let region = "Region"
      public static let label = "Label"
      public static let function = "Function"
      public static let string = "String"
      public static let data = "Data"
      public static let image1bpp = "Image (1bpp)"
      public static let image2bpp = "Image (2bpp)"
    }
    public var regionType: String
    public var name: String
    public var bank: Cartridge.Bank
    public var address: LR35902.Address
    public var length: LR35902.Address
  }

  static public func loadRegions(from data: Data) -> [Region] {
    guard let regionsText = String(data: data, encoding: .utf8) else {
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

  public func regionsAsData() -> Data {
    return regions
      .sorted(by: { $0.bank < $1.bank && $0.address < $1.address })
      .map { (region: Region) -> String in
        "\(region.name): ; [\(region.regionType)] \(RGBDS.asHexString(region.bank)):\(RGBDS.asHexString(region.address)) [\(region.length)]"
      }
      .joined(separator: "\n\n")
      .data(using: .utf8) ?? Data()
  }

  func applyRegions(to configuration: Disassembler.MutableConfiguration) {
    for region: Region in regions {
      let location = Cartridge.Location(address: region.address, bank: region.bank)
      switch region.regionType {
      case Region.Kind.region:
        configuration.registerPotentialCode(at: location..<(location + region.length), named: region.name)

      case Region.Kind.function:
        configuration.registerFunction(startingAt: location, named: region.name)

      case Region.Kind.label:
        configuration.registerLabel(at: location, named: region.name)

      case Region.Kind.string:
        configuration.registerLabel(at: location, named: region.name)
        let startLocation = Cartridge.Location(address: region.address, bank: region.bank)
        configuration.registerText(at: startLocation..<(startLocation + region.length), lineLength: nil)

      case Region.Kind.image1bpp:
        configuration.registerLabel(at: location, named: region.name)
        let startLocation = Cartridge.Location(address: region.address, bank: location.bank)
        configuration.registerData(at: startLocation..<(startLocation + region.length), format: .image1bpp)

      case Region.Kind.image2bpp:
        configuration.registerLabel(at: location, named: region.name)
        let startLocation = Cartridge.Location(address: region.address, bank: location.bank)
        configuration.registerData(at: startLocation..<(startLocation + region.length), format: .image2bpp)

      case Region.Kind.data:
        configuration.registerLabel(at: location, named: region.name)
        let startLocation = Cartridge.Location(address: region.address, bank: location.bank)
        configuration.registerData(at: startLocation..<(startLocation + region.length))

      default:
        break
      }
    }
  }
}
