import Foundation

#if os(macOS)
import os.log
#endif

import CPU
import LR35902
import RGBDS
import Tracing

extension Array {
  public func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}

extension Data {
  public func chunked(into size: Int) -> [Data] {
    return stride(from: startIndex, to: startIndex + count, by: size).map {
      self[$0 ..< Swift.min($0 + size, startIndex + count)]
    }
  }
}

private func stringWithNewline(_ string: String) -> String {
  return string + "\n"
}

func prettify(_ label: String) -> String {
  let parts = label.components(separatedBy: ".")
  if parts.count == 1 {
    return label
  }
  return ".\(parts.last!)"
}

func textLine(for bytes: Data, characterMap: [UInt8: String], address: LR35902.Address) -> Disassembler.Line {
  return Disassembler.Line(semantic: .text(RGBDS.Statement(withAscii: bytes, characterMap: characterMap)),
                           address: address,
                           data: bytes)
}

extension Disassembler {
  func processLines(_ lines: [Line]) -> (source: String, filteredLines: [Line]) {
    var lastLine: Line?
    let filteredLines = lines.filter { thisLine in
      if let lastLine = lastLine, lastLine.semantic == .emptyAndCollapsible && thisLine.semantic == .emptyAndCollapsible {
        return false
      }
      lastLine = thisLine
      return true
    }
    return (filteredLines.map { $0.asString(detailedComments: false) }.joined(separator: "\n"), filteredLines)
  }

  public func generateSource() throws -> (Source, Statistics) {
#if os(macOS)
    let log = OSLog(subsystem: "com.featherless.windfish", category: "PointsOfInterest")
#endif

    var sources: [String: Source.FileDescription] = [:]

    sources["Makefile"] = createMakefile()

    var gameAsm = ""

    if let dataTypesSource = createDataTypesSource() {
      sources["datatypes.asm"] = dataTypesSource
      gameAsm += "INCLUDE \"datatypes.asm\"\n"
    }
    if let variablesSource = createVariablesSource() {
      sources["variables.asm"] = variablesSource
      gameAsm += "INCLUDE \"variables.asm\"\n"
    }
    if let characterMapSource = createCharacterMapSource() {
      sources["charmap.asm"] = characterMapSource
      gameAsm += "INCLUDE \"charmap.asm\"\n"
    }

    // TODO: Source should be generated in a tokenized fashion, such that there is a String representing the source and
    // an array of tokens representing a range and a set of attributes. This will enable the Windfish UI to associate
    // attributes to the string by simply mapping tokens to attributes.

    var macrosToWrite: [Disassembler.EncounteredMacro] = []
    let q = DispatchQueue(label: "sync queue")
    DispatchQueue.concurrentPerform(iterations: configuration.numberOfBanks) { (index: Int) in
#if os(macOS)
      let signpostID = OSSignpostID(log: log)
      os_signpost(.begin, log: log, name: "Generate source", signpostID: signpostID, "%{public}d", index)
#endif

      let worker = BankSourceWorker(context: configuration, bank: Cartridge.Bank(truncatingIfNeeded: index), router: lastBankRouter!, disassembler: self)
      worker.generateSource()

#if os(macOS)
      os_signpost(.end, log: log, name: "Generate source", signpostID: signpostID, "%{public}d", index)
#endif

      q.sync {
        macrosToWrite.append(contentsOf: worker.macrosUsed)

        let (content, filteredBankLines) = processLines(worker.lines)
        sources["bank_\(worker.bank.hexString).asm"] = .bank(number: worker.bank, content: content, lines: filteredBankLines)
      }
    }

    if let macrosSource = createMacrosSource(macrosToWrite: macrosToWrite) {
      sources["macros.asm"] = macrosSource
      gameAsm += "INCLUDE \"macros.asm\"\n"
    }

    gameAsm += ((UInt8(0)..<UInt8(truncatingIfNeeded: configuration.numberOfBanks))
                  .map { "INCLUDE \"bank_\($0.hexString).asm\"" }
                  .joined(separator: "\n") + "\n")

    sources["game.asm"] = .game(content: gameAsm)

    let disassembledLocations = self.lastBankRouter!.disassembledLocations()
    let bankPercents: [Cartridge.Bank: Double] = (0..<configuration.numberOfBanks).reduce(into: [:]) { accumulator, bank in
      let disassembledBankLocations = disassembledLocations.intersection(
        IndexSet(integersIn: (Int(bank) * Int(Cartridge.bankSize))..<(Int(bank + 1) * Int(Cartridge.bankSize)))
      )
      accumulator[Cartridge.Bank(truncatingIfNeeded: bank)] = Double(disassembledBankLocations.count * 100) / Double(Cartridge.bankSize)
    }
    let statistics = Statistics(
      instructionsDecoded: lastBankRouter!.bankWorkers.map { $0.instructionMap.count }.reduce(0, +),
      percent: Double(disassembledLocations.count * 100) / Double(configuration.cartridgeData.count),
      bankPercents: bankPercents
    )

    return (Source(sources: sources), statistics)
  }

  public struct Statistics: Equatable {
    public let instructionsDecoded: Int
    public let percent: Double
    public let bankPercents: [Cartridge.Bank: Double]
  }
}
