import AppKit
import Foundation
import Cocoa

import os.log

import RGBDS
import Tracing
import Windfish

extension ProjectDocument {
  @objc func disassemble(_ sender: Any?) {
    guard let romData: Data = project.romData else {
      return
    }
    project.isDisassembling = true
    self.contentViewController?.startProgressIndicator()

    DispatchQueue.global(qos: .userInitiated).async { () -> Void in
      let disassembly: Disassembler = Disassembler(data: romData)
      self.project.configuration.storage.prepare(disassembly.mutableConfiguration)
      disassembly.willStart()
      self.project.configuration.storage.apply(to: disassembly.mutableConfiguration)
      disassembly.disassemble()

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
              regionType: Windfish.Project.Region.Kind.label,
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

      let labelColor: NSColor = NSColor.systemOrange
      let baseAttributes: WINDStringAttributes = WINDStringAttributes.base()
      let opcodeAttributes: WINDStringAttributes = WINDStringAttributes.opcode()
      let macroNameAttributes: WINDStringAttributes = WINDStringAttributes.macro()
      let commentAttributes: WINDStringAttributes = WINDStringAttributes.comment()
      let operandAttributes: WINDStringAttributes = baseAttributes

      let bankSources: [Cartridge.Bank: (String, [Disassembler.Line])] = disassembledSource.sources.reduce(into: [:], {
        (accumulator: inout [Cartridge.Bank: (String, [Disassembler.Line])],
         element: (key: String, value: Disassembler.Source.FileDescription)) in
        switch element.value {
        case .bank(let bank, _, let lines):
          accumulator[bank] = (element.key, lines)
        default: break
        }
      })

      let log = OSLog(subsystem: "com.featherless.windfish", category: "PointsOfInterest")

      // TODO: Generate attributed text for the currently selected bank immediately and then kick off the other banks
      // once done so that we can return from disassembly faster.
      var bankTextStorage: [Cartridge.Bank: NSAttributedString] = [:]
      let q: DispatchQueue = DispatchQueue(label: "sync queue")
      DispatchQueue.concurrentPerform(iterations: disassembly.mutableConfiguration.numberOfBanks) { (index: Int) in
        let signpostID = OSSignpostID(log: log)
        os_signpost(.begin, log: log, name: "Generate attributed string", signpostID: signpostID, "%{public}d", index)

        let bank: Cartridge.Bank = Cartridge.Bank(truncatingIfNeeded: index)
        let lines: [Disassembler.Line] = bankSources[bank]!.1

        let string: NSAttributedString = lines.reduce(into: NSMutableAttributedString()) { accumulator, line in
          switch line.semantic {
          case .empty: fallthrough
          case .emptyAndCollapsible:
            break // Do nothing.
          case .preComment:
            accumulator.append(commentAttributes.attributedString(with: line.asString(detailedComments: false)))
          case .label: fallthrough
          case .transferOfControl:
            accumulator.append(NSAttributedString(string: line.asString(detailedComments: false), attributes: [
              .foregroundColor: labelColor,
              .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
            ]))
          case .section: fallthrough
          case .macroDefinition: fallthrough
          case .macroTerminator:
            accumulator.append(baseAttributes.attributedString(with: line.asString(detailedComments: false)))
          case let .jumpTable(jumpLocation, index):
            let assembly = RGBDS.Statement(opcode: "dw", operands: [jumpLocation])
            accumulator.append(NSAttributedString(string: "    "))
            accumulator.append(assembly.attributedString(attributes: baseAttributes,
                                                         opcodeAttributes: opcodeAttributes,
                                                         operandAttributes: operandAttributes,
                                                         regionLookup: regionLookup))
            accumulator.append(commentAttributes.attributedString(with: " ; \(UInt8(truncatingIfNeeded: index).hexString)"))
          case let .text(assembly): fallthrough
          case let .data(assembly): fallthrough
          case let .unknown(assembly): fallthrough
          case let .global(assembly, _, _): fallthrough
          case let .image1bpp(assembly): fallthrough
          case let .image2bpp(assembly): fallthrough
          case let .macroInstruction(_, assembly): fallthrough
          case let .instruction(_, assembly):
            accumulator.append(NSAttributedString(string: "    "))
            accumulator.append(assembly.attributedString(attributes: baseAttributes,
                                                         opcodeAttributes: opcodeAttributes,
                                                         operandAttributes: operandAttributes,
                                                         regionLookup: regionLookup))
          case let .macro(assembly):
            accumulator.append(NSAttributedString(string: "    "))
            accumulator.append(assembly.attributedString(attributes: baseAttributes,
                                                         opcodeAttributes: macroNameAttributes,
                                                         operandAttributes: operandAttributes,
                                                         regionLookup: regionLookup))

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
        os_signpost(.end, log: log, name: "Generate attributed string", signpostID: signpostID, "%{public}d", index)

        q.sync {
          bankTextStorage[bank] = string
        }
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
        // TODO: Delete the metadata altogether; there's no need to store this to disk.
        self.project.metadata?.numberOfBanks = Cartridge.Bank(truncatingIfNeeded: disassembly.mutableConfiguration.numberOfBanks)
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
