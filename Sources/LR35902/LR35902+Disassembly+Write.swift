import Foundation

import AssemblyGenerator

extension Array {
  fileprivate func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}

private func write(_ string: String, fileHandle: FileHandle) {
  fileHandle.write("\(string)\n".data(using: .utf8)!)
}

private func line(_ transfersOfControl: Set<LR35902.Disassembly.TransferOfControl>, label: String) -> String {
  let sources = transfersOfControl
    .sorted(by: { $0.sourceAddress < $1.sourceAddress })
    .map { "\($0.kind) @ $\($0.sourceAddress.hexString)" }
    .joined(separator: ", ")
  return line("\(label):", comment: "Sources: \(sources)")
}

extension FileManager {
  fileprivate func restartFile(atPath path: String) throws -> FileHandle {
    if fileExists(atPath: path) {
      try removeItem(atPath: path)
    }
    createFile(atPath: path, contents: Data(), attributes: nil)
    return try FileHandle(forWritingTo: URL(fileURLWithPath: path))
  }
}

extension LR35902.Disassembly {
  enum Line: Equatable {
    case empty
    case preComment(String)
    case label(String)
    case transferOfControl(Set<TransferOfControl>, String)
    case instruction(LR35902.Instruction, String, UInt16, Data)
    case macro(String, UInt16, Data)
  }
  public func writeTo(directory: String, cpu: LR35902) throws {
    let fm = FileManager.default
    let directoryUrl = URL(fileURLWithPath: directory)
    try fm.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)

    let makefileHandle = try fm.restartFile(atPath: directoryUrl.appendingPathComponent("Makefile").path)

    makefileHandle.write(
"""
all: game.gb

game.o: game.asm bank_*.asm
	rgbasm -h -o game.o game.asm

game.gb: game.o
	rgblink -d -n game.sym -m game.map -o $@ $<
	rgbfix -v -p 255 $@

	md5 $@

clean:
	rm -f game.o game.gb game.sym game.map *.o
	find . \\( -iname '*.1bpp' -o -iname '*.2bpp' \\) -exec rm {} +

""".data(using: .utf8)!)

    let gameHandle = try fm.restartFile(atPath: directoryUrl.appendingPathComponent("game.asm").path)

    if !cpu.disassembly.variables.isEmpty {
      let variablesHandle = try fm.restartFile(atPath: directoryUrl.appendingPathComponent("variables.asm").path)

      variablesHandle.write(cpu.disassembly.variables.map { address, name in
        "\(name) EQU $\(address.hexString)"
      }.joined(separator: "\n\n").data(using: .utf8)!)

      gameHandle.write("INCLUDE \"variables.asm\"\n".data(using: .utf8)!)
    }

    gameHandle.write(
      ((UInt8(0)..<UInt8(cpu.numberOfBanks))
        .map { "INCLUDE \"bank_\($0.hexString).asm\"" }
        .joined(separator: "\n") + "\n")
        .data(using: .utf8)!)

    var instructionsToDecode = Int.max

    for bank in UInt8(0)..<UInt8(cpu.numberOfBanks) {
      let fileHandle = try fm.restartFile(atPath: directoryUrl.appendingPathComponent("bank_\(bank.hexString).asm").path)

      if bank == 0 {
        write("SECTION \"ROM Bank \(bank.hexString)\", ROM0[$\(bank.hexString)]", fileHandle: fileHandle)
      } else {
        write("SECTION \"ROM Bank \(bank.hexString)\", ROMX[$4000], BANK[$\(bank.hexString)]", fileHandle: fileHandle)
      }

      cpu.pc = (bank == 0) ? 0x0000 : 0x4000
      cpu.bank = bank
      let end: UInt16 = (bank == 0) ? 0x4000 : 0x8000

      var lineBufferAddress: UInt16 = cpu.pc
      var lineBuffer: [Line] = []
      lineBuffer.append(.empty)
      var macroNode: MacroNode? = nil

      let flush = {
        var lastLine: Line?
        lineBuffer.forEach { thisLine in
          if let lastLine = lastLine, lastLine == .empty && thisLine == .empty {
            return
          }
          switch thisLine {
          case .empty:                             write("", fileHandle: fileHandle)
          case let .label(label):                  write("\(label):", fileHandle: fileHandle)
          case let .preComment(comment):           write(line(comment: comment), fileHandle: fileHandle)
          case let .transferOfControl(toc, label): write(line(toc, label: label), fileHandle: fileHandle)
          case let .instruction(_, assembly, address, bytes): write(line(assembly, address: address, bytes: bytes), fileHandle: fileHandle)
          case let .macro(assembly, address, bytes): write(line(assembly, address: address, bytes: bytes), fileHandle: fileHandle)
          }
          lastLine = thisLine
        }
        lineBuffer.removeAll()
        macroNode = nil
      }

      while cpu.pc < end {
        var lineGroup: [Line] = []
        if let preComment = cpu.disassembly.preComment(at: cpu.pc, in: bank) {
          lineGroup.append(.empty)
          lineGroup.append(.preComment(preComment))
        }
        if let label = cpu.disassembly.label(at: cpu.pc, in: bank) {
          if let transfersOfControl = cpu.disassembly.transfersOfControl(at: cpu.pc, in: bank) {
            lineGroup.append(.transferOfControl(transfersOfControl, label))
          } else {
            lineGroup.append(.empty)
            lineGroup.append(.label(label))
          }
        }

        if instructionsToDecode > 0, let instruction = cpu.disassembly.instruction(at: cpu.pc, in: bank) {
          instructionsToDecode -= 1

          if let bankChange = cpu.disassembly.bankChange(at: cpu.pc, in: bank) {
            cpu.bank = bankChange
          }

          // Write the instruction as assembly.
          let index = LR35902.romAddress(for: cpu.pc, in: bank)
          let bytes = cpu[index..<(index + UInt32(instruction.width))]
          lineGroup.append(.instruction(instruction, RGBDSAssembly.assembly(for: instruction, with: cpu), cpu.pc, bytes))

          cpu.pc += instruction.width

          // Handle context changes.
          switch instruction.spec {
          case .jp, .jr:
            lineGroup.append(.empty)
            cpu.bank = bank
          case .ret, .reti:
            lineGroup.append(.empty)
            lineGroup.append(.empty)
            cpu.bank = bank
          default:
            break
          }

          // Is this the beginning of a macro?
          if macroNode == nil, let child = cpu.disassembly.macroTree.children[instruction.spec] {
            flush()
            lineBufferAddress = cpu.pc - instruction.width
            macroNode = child

          } else if let macroNodeIterator = macroNode {
            // Still building the macro.
            if let child = macroNodeIterator.children[instruction.spec] {
              macroNode = child
            } else {
              if let macro = macroNodeIterator.macro,
                let arguments = macroNodeIterator.arguments {
                let instructions = lineBuffer.compactMap { thisLine -> LR35902.Instruction? in
                  if case let .instruction(instruction, _, _, _) = thisLine {
                    return instruction
                  } else {
                    return nil
                  }
                }
                let assembly = arguments(instructions).joined(separator: ", ")
                lineBuffer.removeAll()

                let lowerBound = LR35902.romAddress(for: lineBufferAddress, in: bank)
                let upperBound = LR35902.romAddress(for: cpu.pc - instruction.width, in: bank)
                let bytes = cpu[lowerBound..<upperBound]
                lineBuffer.append(.macro("\(macro) \(assembly)", lineBufferAddress, bytes))

                lineBufferAddress = cpu.pc
              }
              macroNode = nil
            }
          }

          lineBuffer.append(contentsOf: lineGroup)

        } else {
          lineBuffer.append(contentsOf: lineGroup)
          flush()

          cpu.bank = bank

          // Accumulate bytes until the next instruction or transfer of control.
          var accumulator: [UInt8] = []
          let initialPc = cpu.pc
          let initialType = cpu.disassembly.type(of: cpu.pc, in: bank)
          repeat {
            accumulator.append(cpu[cpu.pc, cpu.bank])
            cpu.pc += 1
          } while cpu.pc < end
            && (instructionsToDecode == 0 || cpu.disassembly.instruction(at: cpu.pc, in: bank) == nil)
            && cpu.disassembly.label(at: cpu.pc, in: bank) == nil
            && cpu.disassembly.type(of: cpu.pc, in: bank) == initialType

          // Dump the bytes in blocks of 8.
          if initialType == .text {
            write(line(RGBDSAssembly.text(for: accumulator), address: initialPc), fileHandle: fileHandle)

          } else {
            var address = initialPc
            for chunk in accumulator.chunked(into: 8) {
              let instruction = RGBDSAssembly.assembly(for: chunk)
              let displayableBytes = chunk.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
              let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""
              write(line(instruction, address: address, comment: "|\(bytesAsCharacters)|"), fileHandle: fileHandle)
              address += UInt16(chunk.count)
            }
          }

          lineBuffer.append(.empty)
          lineBufferAddress = cpu.pc
        }
      }

      flush()
    }
  }
}
