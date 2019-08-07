import Foundation

let romFilePath = "/Users/featherless/workbench/awakenlink/rom/LinksAwakening.gb"
let disassemblyPath = URL(fileURLWithPath: "/Users/featherless/workbench/gbdis/disassembly", isDirectory: true)

let data = try Data(contentsOf: URL(fileURLWithPath: romFilePath))

let cpu = LR35902(rom: data)

cpu.disassemble(startingFrom: 0x0000, inBank: 0)

for bank in UInt8(0)..<UInt8(cpu.numberOfBanks) {
//  let asmUrl = disassemblyPath.appendingPathComponent("bank_\(bank.hexString).asm")

  print("SECTION \"ROM Bank \(bank.hexString)\", ROM0[$\(bank.hexString)]")
  var line: UInt16 = 0x0000
  while line < 0x4000 {
    if cpu.disassembly.jump(at: line, in: bank) != nil {
      print("Jump_\(bank.hexString)_\(line.hexString):")
    }

    if let instruction = cpu.disassembly.instruction(at: line, in: bank) {
      let code = "\(instruction)".padding(toLength: 32, withPad: " ", startingAt: 0)
      print("    \(code) ; $\(line.hexString)")
      line += instruction.width
    } else {
      //print("    ds \(cpu.rom[Int(UInt32(line) + UInt32(bank) * LR35902.bankSize)]) ; \(line.hexString)")
      line += 1
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
