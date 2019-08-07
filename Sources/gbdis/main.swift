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
  var line: UInt16 = 0x0000
  while line < 0x4000 {
    if cpu.disassembly.jump(at: line, in: bank) != nil {
      print("Jump_\(bank.hexString)_\(line.hexString):")
    }

    if let instruction = cpu.disassembly.instruction(at: line, in: bank) {
      let code = "\(instruction)".padding(toLength: 44, withPad: " ", startingAt: 0)
      print("    \(code) ; $\(line.hexString)")
      line += instruction.width
    } else {
      var accumulator: [UInt8] = []
      let initialLine = line
      repeat {
        accumulator.append(cpu.rom[Int(UInt32(line) + UInt32(bank) * LR35902.bankSize)])
        line += 1
      } while line < 0x4000 && cpu.disassembly.instruction(at: line, in: bank) == nil

      var lineBlock = initialLine
      for blocks in accumulator.chunked(into: 8) {
        let operand = blocks.map { "$\($0.hexString)" }.joined(separator: ", ")
        let opcode = "ds".padding(toLength: 5, withPad: " ", startingAt: 0)
        let instruction = "\(opcode) \(operand)"
        let code = "\(instruction)".padding(toLength: 44, withPad: " ", startingAt: 0)

        let displayableBytes = blocks.map { ($0 >= 32 && $0 <= 126) ? $0 : 46 }
        let bytesAsCharacters = String(bytes: displayableBytes, encoding: .ascii) ?? ""

        print("    \(code) ; $\(lineBlock.hexString) |\(bytesAsCharacters)|")
        lineBlock += UInt16(blocks.count)
      }
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
