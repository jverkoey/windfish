import Foundation

import RGBDS

extension Disassembler {
  public struct Line: Equatable {
    public enum ImageFormat {
      case oneBitPerPixel
      case twoBitsPerPixel
    }
    public enum Semantic: Equatable {
      /** An empty line. */
      case empty

      /** Like an empty line, but contiguous blocks of these lines will compact into a single empty line. */
      case emptyAndCollapsible

      case preComment(comment: String)
      case label(labelName: String)
      case section(Cartridge.Bank)
      case transferOfControl(Set<Cartridge.Location>, String)
      case instruction(LR35902.Instruction, RGBDS.Statement)
      case macroInstruction(LR35902.Instruction, RGBDS.Statement)
      case macro(RGBDS.Statement)
      case macroDefinition(String)
      case macroTerminator
      case imagePlaceholder(format: ImageFormat)
      case image1bpp(RGBDS.Statement)
      case image2bpp(RGBDS.Statement)
      case data(RGBDS.Statement)
      case text(RGBDS.Statement)
      case jumpTable(String, Int)
      case unknown(RGBDS.Statement)
      case global(RGBDS.Statement, dataTypeName: String, dataType: MutableConfiguration.Datatype)
    }

    init(semantic: Semantic, address: LR35902.Address? = nil, bank: Cartridge.Bank? = nil, scope: String? = nil, data: Data? = nil) {
      self.semantic = semantic
      self.address = address
      self.bank = bank
      if let scope = scope {
        if scope.isEmpty {
          self.scope = nil
        } else {
          self.scope = scope
        }
      } else {
        self.scope = nil
      }
      self.data = data
    }

    public let semantic: Semantic
    public let address: LR35902.Address?
    public let bank: Cartridge.Bank?
    public let scope: String?
    public let data: Data?

    public func asString(detailedComments: Bool) -> String {
      switch semantic {
      case .empty:                           return ""

      case .emptyAndCollapsible:                             return ""

      case .imagePlaceholder:                  return ""

      case let .label(label):                  return "\(prettify(label)):"

      case let .section(bank):
        if bank == 0 {
          return "SECTION \"ROM Bank \(bank.hexString)\", ROM0[$\(bank.hexString)]"
        } else {
          return "SECTION \"ROM Bank \(bank.hexString)\", ROMX[$4000], BANK[$\(bank.hexString)]"
        }

      case let .preComment(comment):           return line(comment: comment)

      case let .transferOfControl(toc, label):
        if detailedComments {
          let sources = toc
            .sorted(by: { $0 < $1 })
            .map { return RGBDS.NumericPrefix.hexadecimal + $0.address.hexString }
            .joined(separator: ", ")
          return line("\(label):", comment: "Sources: \(sources)")
        } else {
          return line("\(label):", comment: nil)
        }

      case let .instruction(_, assembly):
        if detailedComments {
          return line(assembly.formattedString, address: address!, bank: bank!, scope: scope!, bytes: data!)
        } else {
          return line(assembly.formattedString)
        }

      case let .macroInstruction(_, assembly): return line(assembly.formattedString)

      case let .macro(assembly):
        if detailedComments {
          return line(assembly.formattedString, address: address!, bank: bank!, scope: scope!, bytes: data!)
        } else {
          return line(assembly.formattedString)
        }

      case let .macroDefinition(name):         return "\(name): MACRO"

      case .macroTerminator:                   return line("ENDM")

      case let .text(statement):
        if detailedComments {
          return line(statement.formattedString, address: address!, addressType: "text")
        } else {
          return line(statement.formattedString)
        }

      case let .jumpTable(jumpLocation, index):
        if detailedComments {
          return line("dw \(jumpLocation)", address: address!, addressType: "jumpTable [\(index)]", comment: "\(data!.map { "$\($0.hexString)" }.joined(separator: " "))")
        } else {
          return line("    dw \(jumpLocation) ; \(UInt8(truncatingIfNeeded: index).hexString)", comment: nil)
        }

      case let .image1bpp(statement):
        if detailedComments {
          let displayableBytes = data!.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
          let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""
          return line(statement.formattedString, address: address!, addressType: "image1bpp", comment: "|\(bytesAsCharacters)|")
        } else {
          return line(statement.formattedString)
        }

      case let .image2bpp(statement):
        if detailedComments {
          let displayableBytes = data!.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
          let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""
          return line(statement.formattedString, address: address!, addressType: "image2bpp", comment: "|\(bytesAsCharacters)|")
        } else {
          return line(statement.formattedString)
        }

      case let .data(statement):
        if detailedComments {
          let displayableBytes = data!.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
          let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""
          return line(statement.formattedString, address: address!, addressType: "data", comment: "|\(bytesAsCharacters)|")
        } else {
          return line(statement.formattedString)
        }

      case let .unknown(statement):
        if detailedComments {
          let displayableBytes = data!.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
          let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""
          return line(statement.formattedString, address: address!, addressType: nil, comment: "|\(bytesAsCharacters)|")
        } else {
          return line(statement.formattedString)
        }

      case let .global(statement, addressType, _):
        if detailedComments {
          return line(statement.formattedString, address: address!, addressType: addressType)
        } else {
          return line(statement.formattedString)
        }
      }
    }

    public var description: String {
      return asString(detailedComments: true)
    }

    var asString: String {
      return asString(detailedComments: true) + "\n"
    }

    public var asEditorString: String {
      return asString(detailedComments: false) + "\n"
    }
  }
}
