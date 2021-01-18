import AppKit
import Foundation
import Cocoa

import RGBDS
import Windfish

extension ProjectDocument {
  @objc func disassemble(_ sender: Any?) {
    guard let romData = project.romData else {
      return
    }
    project.isDisassembling = true
    self.contentViewController?.startProgressIndicator()

    DispatchQueue.global(qos: .userInitiated).async {
      let disassembly = Disassembler(data: romData)

      for dataType in self.project.configuration.dataTypes {
        let mappingDict = dataType.mappings.reduce(into: [:]) { accumulator, mapping in
          accumulator[mapping.value] = mapping.name
        }
        let representation: Disassembler.Datatype.Representation
        switch dataType.representation {
        case DataType.Representation.binary:
          representation = .binary
        case DataType.Representation.decimal:
          representation = .decimal
        case DataType.Representation.hexadecimal:
          representation = .hexadecimal
        default:
          preconditionFailure()
        }
        switch dataType.interpretation {
        case DataType.Interpretation.any:
          disassembly.createDatatype(named: dataType.name, representation: representation)
        case DataType.Interpretation.bitmask:
          disassembly.createDatatype(named: dataType.name, bitmask: mappingDict, representation: representation)
        case DataType.Interpretation.enumerated:
          disassembly.createDatatype(named: dataType.name, enumeration: mappingDict, representation: representation)
        default:
          preconditionFailure()
        }
      }

      for global in self.project.configuration.globals {
        disassembly.createGlobal(at: global.address, named: global.name, dataType: global.dataType)
      }

      // Integrate scripts before any disassembly in order to allow the scripts to modify the disassembly runs.
      for script in self.project.configuration.scripts {
        disassembly.defineScript(named: script.name, source: script.source)
      }

      disassembly.willStart()

      // Disassemble everything first
      for region in self.project.configuration.regions {
        let bank = max(1, region.bank)
        switch region.regionType {
        case Region.Kind.region:
          disassembly.setLabel(at: region.address, in: bank, named: region.name)
          if region.length > 0 {
            disassembly.disassemble(range: region.address..<(region.address + region.length), inBank: bank)
          }
        case Region.Kind.function:
          disassembly.defineFunction(startingAt: region.address, in: bank, named: region.name)
        default:
          break
        }
      }

      // And then set any explicit regions
      for region in self.project.configuration.regions {
        let bank = max(1, region.bank)
        switch region.regionType {
        case Region.Kind.label:
          disassembly.setLabel(at: region.address, in: bank, named: region.name)
        case Region.Kind.string:
          disassembly.setLabel(at: region.address, in: bank, named: region.name)
          disassembly.setText(at: region.address..<(region.address + region.length), in: bank, lineLength: nil)
        case Region.Kind.image1bpp:
          disassembly.setLabel(at: region.address, in: bank, named: region.name)
          disassembly.setData(at: region.address..<(region.address + region.length), in: bank, format: .image1bpp)
        case Region.Kind.image2bpp:
          disassembly.setLabel(at: region.address, in: bank, named: region.name)
          disassembly.setData(at: region.address..<(region.address + region.length), in: bank, format: .image2bpp)
        case Region.Kind.data:
          disassembly.setLabel(at: region.address, in: bank, named: region.name)
          disassembly.setData(at: region.address..<(region.address + region.length), in: bank)
        default:
          break
        }
      }

      for macro in self.project.configuration.macros {
        disassembly.defineMacro(named: macro.name, template: macro.source)
      }

      //            disassembly.disassembleAsGameboyCartridge()
      let (disassembledSource, statistics) = try! disassembly.generateSource()

      let bankMap: [String: Cartridge.Bank] = disassembledSource.sources.reduce(into: [:], { accumulator, element in
        if case .bank(let number, _, _) = element.value {
          accumulator[element.key] = number
        }
      })
      let bankLines: [Cartridge.Bank: [Disassembler.Line]] = disassembledSource.sources.compactMapValues {
        switch $0 {
        case .bank(_, _, let lines):
          return lines
        default:
          return nil
        }
      }.reduce(into: [:]) { accumulator, entry in
        accumulator[bankMap[entry.0]!] = entry.1
      }

      var regionLookup: [String: Region] = [:]
      let regions: [Region] = bankLines.reduce(into: []) { accumulator, element in
        let bank = element.key
        accumulator.append(contentsOf: element.value.reduce(into: []) { accumulator, line in
          switch line.semantic {
          case let .label(name): fallthrough
          case let .transferOfControl(_, name):
            let region = Region(
              regionType: Region.Kind.label,
              name: name,
              bank: bank,
              address: line.address!,
              length: 0
            )
            accumulator.append(region)
            regionLookup[name] = region
            break
          default:
            break
          }
        })
      }

      let commentColor = NSColor.systemGreen
      let labelColor = NSColor.systemOrange
      let baseAttributes: [NSAttributedString.Key : Any] = [
        .foregroundColor: NSColor.textColor,
        .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
      ]
      let opcodeAttributes: [NSAttributedString.Key : Any] = [
        .foregroundColor: NSColor.systemGreen,
        .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
      ]
      let macroNameAttributes: [NSAttributedString.Key : Any] = [
        .foregroundColor: NSColor.systemBrown,
        .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
      ]
      let commentAttributes: [NSAttributedString.Key : Any] = [
        .foregroundColor: commentColor,
        .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
      ]
      let operandAttributes: [NSAttributedString.Key : Any] = baseAttributes

      let bankTextStorage: [Cartridge.Bank: NSAttributedString] = disassembledSource.sources.compactMapValues {
        switch $0 {
        case .bank(_, _, let lines):
          return lines.reduce(into: NSMutableAttributedString()) { accumulator, line in
            switch line.semantic {
            case .newline: fallthrough
            case .empty:
              break // Do nothing.
            case .macroComment: fallthrough
            case .preComment:
              accumulator.append(NSAttributedString(string: line.asString(detailedComments: false),
                                                    attributes: commentAttributes))
            case .label: fallthrough
            case .transferOfControl:
              accumulator.append(NSAttributedString(string: line.asString(detailedComments: false), attributes: [
                .foregroundColor: labelColor,
                .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
              ]))
            case .section: fallthrough
            case .macroDefinition: fallthrough
            case .macroTerminator:
              accumulator.append(NSAttributedString(string: line.asString(detailedComments: false),
                                                    attributes: baseAttributes))
            case let .jumpTable(jumpLocation, index):
              let assembly = RGBDS.Statement(opcode: "dw", operands: [jumpLocation])
              accumulator.append(NSAttributedString(string: "    ", attributes: baseAttributes))
              accumulator.append(assembly.attributedString(attributes: baseAttributes,
                                                           opcodeAttributes: opcodeAttributes,
                                                           operandAttributes: operandAttributes,
                                                           regionLookup: regionLookup,
                                                           scope: line.scope))
              accumulator.append(NSAttributedString(string: " ; \(UInt8(truncatingIfNeeded: index).hexString)",
                                                    attributes: commentAttributes))
            case let .text(assembly): fallthrough
            case let .data(assembly): fallthrough
            case let .unknown(assembly): fallthrough
            case let .global(assembly, _, _): fallthrough
            case let .image1bpp(assembly): fallthrough
            case let .image2bpp(assembly): fallthrough
            case let .macroInstruction(_, assembly): fallthrough
            case let .instruction(_, assembly):
              accumulator.append(NSAttributedString(string: "    ", attributes: baseAttributes))
              accumulator.append(assembly.attributedString(attributes: baseAttributes,
                                                           opcodeAttributes: opcodeAttributes,
                                                           operandAttributes: operandAttributes,
                                                           regionLookup: regionLookup,
                                                           scope: line.scope))
            case let .macro(assembly):
              accumulator.append(NSAttributedString(string: "    ", attributes: baseAttributes))
              accumulator.append(assembly.attributedString(attributes: baseAttributes,
                                                           opcodeAttributes: macroNameAttributes,
                                                           operandAttributes: operandAttributes,
                                                           regionLookup: regionLookup,
                                                           scope: line.scope))

            case let .imagePlaceholder(format):
              switch format {
              case .oneBitPerPixel:
                let data = line.data!
                let scale: CGFloat = 4
                let imageSize = NSSize(width: 48 * scale + 4 * scale, height: 8 * scale + 4 * scale)
                let image = NSImage(size: imageSize)
                image.lockFocusFlipped(true)
                NSColor.textColor.set()

                var column: CGFloat = 0
                var row: CGFloat = 0
                let pixel = NSRect(x: 2 * scale, y: 2 * scale, width: scale, height: scale)
                var alternator = false
                for byte in data {
                  if (byte & 0x80) != 0 {
                    pixel.offsetBy(dx: column, dy: row).fill()
                  }
                  if (byte & 0x40) != 0 {
                    pixel.offsetBy(dx: column + 1 * scale, dy: row).fill()
                  }
                  if (byte & 0x20) != 0 {
                    pixel.offsetBy(dx: column + 2 * scale, dy: row).fill()
                  }
                  if (byte & 0x10) != 0 {
                    pixel.offsetBy(dx: column + 3 * scale, dy: row).fill()
                  }
                  if (byte & 0x08) != 0 {
                    pixel.offsetBy(dx: column, dy: row + 1 * scale).fill()
                  }
                  if (byte & 0x04) != 0 {
                    pixel.offsetBy(dx: column + 1 * scale, dy: row + 1 * scale).fill()
                  }
                  if (byte & 0x02) != 0 {
                    pixel.offsetBy(dx: column + 2 * scale, dy: row + 1 * scale).fill()
                  }
                  if (byte & 0x01) != 0 {
                    pixel.offsetBy(dx: column + 3 * scale, dy: row + 1 * scale).fill()
                  }
                  if alternator {
                    column += 4 * scale
                    row -= 2 * scale
                  } else {
                    row += 2 * scale
                  }
                  alternator = !alternator
                  if column >= (imageSize.width - 4 * scale) {
                    column = 0
                    row += 4 * scale
                  }
                }

                image.unlockFocus()

                let textAttachment = NSTextAttachment()
                textAttachment.image = image
                accumulator.append(NSAttributedString(attachment: textAttachment))
              case .twoBitsPerPixel:
                let data = line.data!
                let scale: CGFloat = 8
                let tiles = data.count / 16
                let totalColumns = min(8, (tiles + 1) / 2)
                let totalRows = (tiles - 1) / 16 * 2 + ((tiles - 1) % 16 >= 1 ? 2 : 1)
                let imageSize = NSSize(width: CGFloat(totalColumns) * 8 * scale + 4 * scale,
                                       height: CGFloat(totalRows) * 8 * scale + 4 * scale)
                let image = NSImage(size: imageSize)
                image.lockFocusFlipped(true)
                NSColor.textColor.set()

                let colorForBytePair: (UInt8, UInt8, UInt8) -> UInt8 = { highByte, lowByte, bit in
                  let mask = UInt8(0x01) << bit
                  return (((highByte & mask) >> bit) << 1) | ((lowByte & mask) >> bit)
                }

                let colors: [NSColor] = [
                  .black,
                  .darkGray,
                  .lightGray,
                  .white,
                ]

                var tileColumn = 0
                var tileRow = 0
                var pixelRow = 0
                let pixel = NSRect(x: 2 * scale, y: 2 * scale, width: scale, height: scale)
                for bytePairs in [UInt8](data).chunked(into: 2) {
                  let lowByte = bytePairs.first!
                  let highByte = bytePairs.last!

                  for i: UInt8 in 0..<8 {
                    colors[Int(colorForBytePair(highByte, lowByte, 7 - i))].set()
                    pixel.offsetBy(dx: CGFloat(tileColumn) * 8 * scale + CGFloat(i) * scale,
                                   dy: CGFloat(tileRow) * 8 * scale + CGFloat(pixelRow) * scale).fill()
                  }
                  pixelRow += 1
                  if pixelRow >= 16 {
                    tileColumn += 1
                    pixelRow = 0

                    if tileColumn >= 8 {
                      tileColumn = 0
                      tileRow += 2
                    }
                  }
                }

                image.unlockFocus()

                let textAttachment = NSTextAttachment()
                textAttachment.image = image
                accumulator.append(NSAttributedString(attachment: textAttachment))
                break
              }
              break
            }
            accumulator.append(NSAttributedString(string: "\n"))
          }
        default:
          return nil
        }
      }.reduce(into: [:]) { accumulator, entry in
        accumulator[bankMap[entry.0]!] = entry.1
      }
      let disassemblyFiles: [String: Data] = disassembledSource.sources.mapValues {
        switch $0 {
        case .bank(_, let content, _): fallthrough
        case .charmap(content: let content): fallthrough
        case .datatypes(content: let content): fallthrough
        case .game(content: let content): fallthrough
        case .macros(content: let content): fallthrough
        case .makefile(content: let content): fallthrough
        case .variables(content: let content):
          return content.data(using: .utf8)!
        }
      }

      DispatchQueue.main.async {
        self.project.metadata?.numberOfBanks = disassembly.numberOfBanks
        self.project.metadata?.bankMap = bankMap
        self.project.disassemblyResults = DisassemblyResults(
          files: disassemblyFiles,
          bankLines: bankLines,
          bankTextStorage: bankTextStorage,
          regions: regions,
          regionLookup: regionLookup,
          statistics: statistics,
          disassembly: disassembly
        )

        self.project.isDisassembling = false
        NotificationCenter.default.post(name: .disassembled, object: self.project)

        self.contentViewController?.stopProgressIndicator()
      }
    }
  }
}
