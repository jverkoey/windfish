import Foundation

let romFilePath = "/Users/featherless/workbench/awakenlink/rom/LinksAwakening.gb"
let disassemblyPath = URL(fileURLWithPath: "/Users/featherless/workbench/gbdis/disassembly", isDirectory: true)

let data = try Data(contentsOf: URL(fileURLWithPath: romFilePath))

let cpu = LR35902(rom: data)

cpu.disassemble(startingFrom: 0x0000, inBank: 0)

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
