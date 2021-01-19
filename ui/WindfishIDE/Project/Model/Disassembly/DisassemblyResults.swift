import Foundation

import Windfish

final class DisassemblyResults: NSObject {
  internal init(
    files: [String: Data],
    bankLines: [Cartridge.Bank: [Disassembler.Line]]? = nil,
    bankTextStorage: [Cartridge.Bank: NSAttributedString]? = nil,
    regions: [Region]? = nil,
    regionLookup: [String: Region]? = nil,
    statistics: Disassembler.Statistics? = nil,
    disassembly: Disassembler? = nil
  ) {
    self.files = files
    self.bankLines = bankLines
    self.bankTextStorage = bankTextStorage
    self.regions = regions
    self.regionLookup = regionLookup
    self.statistics = statistics
    self.disassembly = disassembly
  }

  func lineFor(address: LR35902.Address, bank unsafeBank: Cartridge.Bank) -> Int? {
    let bank = (address < 0x4000) ? 0 : unsafeBank
    guard let bankLines = bankLines?[bank] else {
      return nil
    }
    var previousLineIndex: Int?
    var lineIndex: Int?
    outerLoop: for (index, line) in bankLines.enumerated() {
      switch line.semantic {
      case .instruction, .macro:
        if let lineAddress = line.address {
          if lineAddress >= address {
            lineIndex = index
            break outerLoop
          }
        }
        previousLineIndex = index
        fallthrough
      default:
        break
      }
    }
    guard let foundLineIndex = lineIndex else {
      return nil
    }
    if let lineAddress = bankLines[foundLineIndex].address, lineAddress > address,
       let previousLineIndex = previousLineIndex {
      // In between lines, so return the previous line.
      return previousLineIndex
    }
    return foundLineIndex
  }

  var files: [String: Data]
  var bankLines: [Cartridge.Bank: [Disassembler.Line]]?
  var bankTextStorage: [Cartridge.Bank: NSAttributedString]?
  @objc dynamic var regions: [Region]?
  var regionLookup: [String: Region]?
  var statistics: Disassembler.Statistics?
  var disassembly: Disassembler?
}
