import Foundation

let romFilePath = "/Users/featherless/workbench/awakenlink/rom/LinksAwakening.gb"
let disassemblyPath = URL(fileURLWithPath: "/Users/featherless/workbench/gbdis/disassembly", isDirectory: true)

let data = try Data(contentsOf: URL(fileURLWithPath: romFilePath))

let cpu = LR35902(rom: data)

cpu.disassemble(range: 0x0000..<0x0008, inBank: 0)
cpu.disassemble(range: 0x0008..<0x0010, inBank: 0)
cpu.disassemble(range: 0x0010..<0x0018, inBank: 0)
cpu.disassemble(range: 0x0018..<0x0020, inBank: 0)
cpu.disassemble(range: 0x0020..<0x0028, inBank: 0)
cpu.disassemble(range: 0x0028..<0x0030, inBank: 0)
cpu.disassemble(range: 0x0030..<0x0038, inBank: 0)
cpu.disassemble(range: 0x0038..<0x0040, inBank: 0)
cpu.disassemble(range: 0x0100..<0x4000, inBank: 0)

extension Array {
  func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}

func print(_ string: String, fileHandle: FileHandle) {
  print(string)
  fileHandle.write("\(string)\n".data(using: .utf8)!)
}

let fm = FileManager.default
try fm.createDirectory(at: disassemblyPath, withIntermediateDirectories: true, attributes: nil)


var instructionsToDecode = Int.max

for bank in UInt8(0)..<UInt8(cpu.numberOfBanks) {
  let asmUrl = disassemblyPath.appendingPathComponent("bank_\(bank.hexString).asm")
  if fm.fileExists(atPath: asmUrl.path) {
    try fm.removeItem(atPath: asmUrl.path)
  }
  fm.createFile(atPath: asmUrl.path, contents: Data(), attributes: nil)
  let fileHandle = try FileHandle(forWritingTo: asmUrl)

  if bank == 0 {
    print("SECTION \"ROM Bank \(bank.hexString)\", ROM0[$\(bank.hexString)]", fileHandle: fileHandle)
  } else {
    print("SECTION \"ROM Bank \(bank.hexString)\", ROMX[$4000], BANK[$\(bank.hexString)]", fileHandle: fileHandle)
  }
  print("", fileHandle: fileHandle)

  cpu.pc = (bank == 0) ? 0x0000 : 0x4000
  cpu.bank = bank
  let end: UInt16 = (bank == 0) ? 0x4000 : 0x8000
  var previousInstruction: LR35902.Instruction? = nil
  while cpu.pc < end {
    if let transfersOfControl = cpu.disassembly.transfersOfControl(at: cpu.pc, in: bank) {
      let sources = transfersOfControl
        .sorted(by: { $0.sourceAddress < $1.sourceAddress })
        .map { "\($0.kind) @ $\($0.sourceAddress.hexString)" }
        .joined(separator: ", ")
      let label = "\(LR35902.label(at: cpu.pc, in: cpu.bank)):".padding(toLength: 48, withPad: " ", startingAt: 0)
      print("\(label) ; Sources: \(sources)", fileHandle: fileHandle)
    }

    // Code
    if instructionsToDecode > 0,
      let instruction = cpu.disassembly.instruction(at: cpu.pc, in: bank) {
      instructionsToDecode -= 1
      if case .ld(.immediate16address, .a) = instruction.spec {
        if (0x2000..<0x4000).contains(instruction.immediate16!),
          let previousInstruction = previousInstruction,
          case .ld(.a, .immediate8) = previousInstruction.spec {
          cpu.bank = previousInstruction.immediate8!
        }
      }

      let code = "    \(instruction.describe(with: cpu))".padding(toLength: 48, withPad: " ", startingAt: 0)
      let index = LR35902.romAddress(for: cpu.pc, in: cpu.bank)
      let bytes = cpu.rom[index..<(index + UInt32(instruction.width))]
      print("\(code) ; $\(cpu.pc.hexString): \(bytes.map { "$\($0.hexString)" }.joined(separator: " "))", fileHandle: fileHandle)
      cpu.pc += instruction.width
      switch instruction.spec {
      case .jp, .jr:
        print("", fileHandle: fileHandle)
        previousInstruction = nil
        cpu.bank = bank
      case .ret, .reti:
        print("", fileHandle: fileHandle); print("", fileHandle: fileHandle)
        previousInstruction = nil
        cpu.bank = bank
      default:
        previousInstruction = instruction
      }

    } else {
      previousInstruction = nil
      cpu.bank = bank

      // Everything else
      var accumulator: [UInt8] = []
      let initialPc = cpu.pc
      repeat {
        accumulator.append(cpu[cpu.pc, cpu.bank])
        cpu.pc += 1
      } while cpu.pc < end
        && (instructionsToDecode == 0 || cpu.disassembly.instruction(at: cpu.pc, in: bank) == nil)
        && cpu.disassembly.transfersOfControl(at: cpu.pc, in: bank) == nil

      var lineBlock = initialPc
      for blocks in accumulator.chunked(into: 8) {
        let operand = blocks.map { "$\($0.hexString)" }.joined(separator: ", ")
        let opcode = "db".padding(toLength: 4, withPad: " ", startingAt: 0)
        let instruction = "\(opcode) \(operand)"
        let code = "    \(instruction)".padding(toLength: 48, withPad: " ", startingAt: 0)

        let displayableBytes = blocks.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
        let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""

        print("\(code) ; $\(lineBlock.hexString) |\(bytesAsCharacters)|", fileHandle: fileHandle)
        lineBlock += UInt16(blocks.count)
      }
      print("", fileHandle: fileHandle)
    }
  }
}

print("code \(Float(cpu.disassembly.code.count) * 100 / Float(cpu.rom.count))%")
