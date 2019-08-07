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
cpu.disassemble(range: 0x0150..<0x4000, inBank: 0)

extension Array {
  func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}

for bank in UInt8(0)..<UInt8(cpu.numberOfBanks) {
//  let asmUrl = disassemblyPath.appendingPathComponent("bank_\(bank.hexString).asm")

  print("SECTION \"ROM Bank \(bank.hexString)\", ROM0[$\(bank.hexString)]")
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
      print("\(label) ; Sources: \(sources)")
    }

    // Code
    if let instruction = cpu.disassembly.instruction(at: cpu.pc, in: bank) {

      if case .ld(.immediate16address, .a) = instruction.spec {
        if (0x2000..<0x4000).contains(instruction.immediate16!),
          let previousInstruction = previousInstruction,
          case .ld(.a, .immediate8) = previousInstruction.spec {
          cpu.bank = previousInstruction.immediate8!
        }
      }

      let code = "    \(instruction.describe(with: cpu))".padding(toLength: 48, withPad: " ", startingAt: 0)
      print("\(code) ; $\(cpu.pc.hexString)")
      cpu.pc += instruction.width
      switch instruction.spec {
      case .jp, .jr:
        print()
        previousInstruction = nil
        cpu.bank = bank
      case .ret, .reti, .retC:
        print(); print()
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
        accumulator.append(cpu.rom[Int(LR35902.romAddress(for: cpu.pc, in: bank))])
        cpu.pc += 1
      } while cpu.pc < end && cpu.disassembly.instruction(at: cpu.pc, in: bank) == nil

      var lineBlock = initialPc
      for blocks in accumulator.chunked(into: 8) {
        let operand = blocks.map { "$\($0.hexString)" }.joined(separator: ", ")
        let opcode = "ds".padding(toLength: 5, withPad: " ", startingAt: 0)
        let instruction = "\(opcode) \(operand)"
        let code = "    \(instruction)".padding(toLength: 48, withPad: " ", startingAt: 0)

        let displayableBytes = blocks.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
        let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""

        print("\(code) ; $\(lineBlock.hexString) |\(bytesAsCharacters)|")
        lineBlock += UInt16(blocks.count)
      }
      print()
    }
  }
}

//func disassemble(in bank: UInt64, at pc: UInt16) -> LR35902.Instruction? {
//  let pcInBank = bank * bankSize + UInt64(pc)
//  guard let opcode = LR35902.OpCode(rawValue: data[Int(pcInBank)]) else {
//    return nil
//  }
//  return LR35902.Instruction(opcode: opcode)
//}
//
//(0..<numberOfBanks).forEach { bank in
////  let asmUrl = disassemblyPath.appendingPathComponent("bank_\(bank.hexString).asm")
//
////  let bankROMRange = (bank * bankSize)..<((bank + 1) * bankSize)
//
//  let pc: UInt16 = 0
//  if let inst = instruction(in: bank, at: pc) {
//    let something = data.suffix(from: Int(pc + 1))
//    print(inst.assemblyRepresentation(something))
//  }
//}
