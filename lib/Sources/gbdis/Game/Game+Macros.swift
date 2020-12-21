import Foundation
import Windfish
import DisassemblyRequest

func populateRequestWithGameMacros(_ request: DisassemblyRequest<LR35902.Address, Gameboy.Cartridge.Location, LR35902.Instruction>) {
  request.createMacro(named: "jumpTable", pattern: [
    .instruction(.init(spec: .rst(.x00))),
    ]) /*{ args, address, bank in
   print("disassembleJumpTable(within: 0x\((address + 1).hexString)..<0x\((address + 3).hexString), in: 0x\(bank.hexString), selectedBank: 0x\(bank.hexString))")
   }*/

  request.createMacro(named: "callcb", pattern: [
    .any(.ld(.a, .imm8), argumentText: "bank(\\1)"),
    .instruction(.init(spec: .ld(.imm16addr, .a), imm16: 0x2100)),
    .any(.call(nil, .imm16), argument: 1)
  ], validArgumentValues: [
    1: IndexSet(integersIn: 0x4000..<0x8000)
  ])

  request.createMacro(named: "modifySave", pattern: [
    .any(.ld(.a, .imm8), argument: 2),
    .any(.ld(.imm16addr, .a), argument: 1)
  ], validArgumentValues: [
    1: IndexSet(integersIn: 0xA100..<0xAB8F)
  ])

  request.createMacro(named: "changebank", pattern: [
    .any(.ld(.a, .imm8), argument: 1),
    .instruction(.init(spec: .ld(.imm16addr, .a), imm16: 0x2100)),
  ])

  request.createMacro(named: "_changebank", pattern: [
    .any(.ld(.a, .imm8), argument: 1),
    .instruction(.init(spec: .call(nil, .imm16), imm16: 0x07b9))
  ])

  request.createMacro(named: "__changebank", pattern: [
    .instruction(.init(spec: .ld(.hl, .imm16), imm16: 0x2100)),
    .any(.ld(.hladdr, .imm8), argument: 1),
  ])

  // TODO: Add validation for a label existing for a given argument.
  //request.createMacro(named: "_callcb", pattern: [
  //  .any(.ld(.a, .imm8)),
  //  .instruction(.init(spec: .call(nil, .imm16), imm16: 0x07b9)),
  //  .any(.call(nil, .imm16))
  //], code: [
  //  .ld(.a, .macro("bank(\\1)")),
  //  .call(nil, .imm16),
  //  .call(nil, .arg(1))
  //], validArgumentValues: [
  //  1: IndexSet(integersIn: 0x4000..<0x8000)
  //])

  request.createMacro(named: "copyRegion", pattern: [
    .any(.ld(.hl, .imm16), argument: 1),
    .any(.ld(.de, .imm16), argument: 3),
    .any(.ld(.bc, .imm16), argument: 2),
    .instruction(.init(spec: .call(nil, .imm16), imm16: 0x28C5)),
    ]) /*{ args, address, bank in
   print("disassembly.setData(at: \(args[1]!)..<(\(args[1]!) + \(args[2]!)), in: 0x\(bank.hexString))")
   }*/

  request.createMacro(named: "copyRegion_", pattern: [
    .any(.ld(.hl, .imm16), argument: 1),
    .any(.ld(.de, .imm16), argument: 3),
    .any(.ld(.bc, .imm16), argument: 2),
    .instruction(.init(spec: .jp(nil, .imm16), imm16: 0x28C5)),
    ]) /*{ args, address, bank in
   print("disassembly.setData(at: \(args[1]!)..<(\(args[1]!) + \(args[2]!)), in: 0x\(bank.hexString))")
   }*/

  request.createMacro(named: "copyRegion__", pattern: [
    .any(.ld(.de, .imm16), argument: 3),
    .any(.ld(.hl, .imm16), argument: 1),
    .any(.ld(.bc, .imm16), argument: 2),
    .instruction(.init(spec: .jp(nil, .imm16), imm16: 0x28C5)),
    ]) /*{ args, address, bank in
   print("disassembly.setData(at: \(args[1]!)..<(\(args[1]!) + \(args[2]!)), in: 0x\(bank.hexString))")
   }*/

  request.createMacro(named: "ifAnyPressed", pattern: [
    .instruction(.init(spec: .ld(.a, .ffimm8addr), imm8: 0xcb)),
    .any(.and(.imm8), argument: 1),
    .any(.jr(.nz, .simm8), argument: 2),
  ])

  request.createMacro(named: "ifNotPressed", pattern: [
    .instruction(.init(spec: .ld(.a, .ffimm8addr), imm8: 0xcb)),
    .any(.and(.imm8), argument: 1),
    .any(.jr(.z, .simm8), argument: 2),
  ])

}
