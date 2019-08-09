import AssemblyGenerator
import Foundation

extension LR35902 {

  /// A class that owns and manages disassembly information for a given ROM.
  public class Disassembly {

    // MARK: - Querying disassembly information.

    // Indexes of bytes that are known to be code.
    public var code = IndexSet()

    // MARK: - Labels

    public func label(at pc: UInt16, in bank: UInt8) -> String? {
      return labels[LR35902.romAddress(for: pc, in: bank)]
    }

    public func setLabel(at pc: UInt16, in bank: UInt8, named name: String) {
      labels[LR35902.romAddress(for: pc, in: bank)] = name
    }
    private var labels: [UInt32: String] = [:]

    // MARK: - Transfers of control

    public struct TransferOfControl: Hashable {
      public enum Kind {
        case jr, jp, call
      }
      public let sourceAddress: UInt16
      public let kind: Kind
    }
    public func transfersOfControl(at pc: UInt16, in bank: UInt8) -> Set<TransferOfControl>? {
      return transfers[LR35902.romAddress(for: pc, in: bank)]
    }

    func registerTransferOfControl(to pc: UInt16, in bank: UInt8, from fromPc: UInt16, kind: TransferOfControl.Kind) {
      let index = LR35902.romAddress(for: pc, in: bank)
      transfers[index, default: Set()]
        .insert(TransferOfControl(sourceAddress: fromPc, kind: kind))
      if labels[index] == nil {
        labels[index] = RGBDSAssembly.defaultLabel(at: pc, in: bank)
      }
    }
    private var transfers: [UInt32: Set<TransferOfControl>] = [:]

    // MARK: - Instructions

    public func instruction(at pc: UInt16, in bank: UInt8) -> Instruction? {
      return instructionMap[LR35902.romAddress(for: pc, in: bank)]
    }

    func register(instruction: Instruction, at pc: UInt16, in bank: UInt8) {
      let address = LR35902.romAddress(for: pc, in: bank)
      instructionMap[address] = instruction

      code.insert(integersIn: Int(address)..<(Int(address) + Int(instruction.width)))
    }
    private var instructionMap: [UInt32: Instruction] = [:]

    // MARK: - Bank changes

    public func bankChange(at pc: UInt16, in bank: UInt8) -> UInt8? {
      return bankChanges[LR35902.romAddress(for: pc, in: bank)]
    }

    func register(bankChange: UInt8, at pc: UInt16, in bank: UInt8) {
      bankChanges[LR35902.romAddress(for: pc, in: bank)] = bankChange
    }
    private var bankChanges: [UInt32: UInt8] = [:]
  }
}

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

private func line(_ transfersOfControl: Set<LR35902.Disassembly.TransferOfControl>, cpu: LR35902) -> String {
  let sources = transfersOfControl
    .sorted(by: { $0.sourceAddress < $1.sourceAddress })
    .map { "\($0.kind) @ $\($0.sourceAddress.hexString)" }
    .joined(separator: ", ")
  let label = cpu.disassembly.label(at: cpu.pc, in: cpu.bank)!
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
      write("", fileHandle: fileHandle)

      cpu.pc = (bank == 0) ? 0x0000 : 0x4000
      cpu.bank = bank
      let end: UInt16 = (bank == 0) ? 0x4000 : 0x8000

      while cpu.pc < end {
        if let transfersOfControl = cpu.disassembly.transfersOfControl(at: cpu.pc, in: bank) {
          write(line(transfersOfControl, cpu: cpu), fileHandle: fileHandle)
        } else if let label = cpu.disassembly.label(at: cpu.pc, in: bank) {
          write("\(label):", fileHandle: fileHandle)
        }

        if instructionsToDecode > 0, let instruction = cpu.disassembly.instruction(at: cpu.pc, in: bank) {
          instructionsToDecode -= 1

          if let bankChange = cpu.disassembly.bankChange(at: cpu.pc, in: bank) {
            cpu.bank = bankChange
          }

          // Write the instruction as assembly.
          let index = LR35902.romAddress(for: cpu.pc, in: cpu.bank)
          let bytes = cpu[index..<(index + UInt32(instruction.width))]
          write(line(RGBDSAssembly.assembly(for: instruction, with: cpu), address: cpu.pc, bytes: bytes), fileHandle: fileHandle)

          cpu.pc += instruction.width

          // Handle context changes.
          switch instruction.spec {
          case .jp, .jr:
            write("", fileHandle: fileHandle)
            cpu.bank = bank
          case .ret, .reti:
            write("", fileHandle: fileHandle)
            write("", fileHandle: fileHandle)
            cpu.bank = bank
          default:
            break
          }

        } else {
          cpu.bank = bank

          // Accumulate bytes until the next instruction or transfer of control.
          var accumulator: [UInt8] = []
          let initialPc = cpu.pc
          repeat {
            accumulator.append(cpu[cpu.pc, cpu.bank])
            cpu.pc += 1
          } while cpu.pc < end
            && (instructionsToDecode == 0 || cpu.disassembly.instruction(at: cpu.pc, in: bank) == nil)
            && cpu.disassembly.label(at: cpu.pc, in: bank) == nil

          // Dump the bytes in blocks of 8.
          var address = initialPc
          for chunk in accumulator.chunked(into: 8) {
            let instruction = RGBDSAssembly.assembly(for: chunk)
            let displayableBytes = chunk.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
            let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""
            write(line(instruction, address: address, comment: "|\(bytesAsCharacters)|"), fileHandle: fileHandle)
            address += UInt16(chunk.count)
          }
          write("", fileHandle: fileHandle)
        }
      }
    }
  }
}
