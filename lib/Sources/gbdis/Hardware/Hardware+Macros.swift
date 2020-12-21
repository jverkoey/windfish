import Foundation
import Windfish
import DisassemblyRequest

func populateRequestWithHardwareMacros(_ request: DisassemblyRequest<LR35902.Address, Gameboy.Cartridge.Location, LR35902.Instruction>) {
  request.createMacro(named: "ifHGte", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .any(.cp(.imm8), argument: 2),
    .any(.jr(.nc, .simm8), argument: 3),
  ])

  request.createMacro(named: "ifHLt", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .any(.cp(.imm8), argument: 2),
    .any(.jr(.c, .simm8), argument: 3),
  ])

  request.createMacro(named: "_ifLt", pattern: [
    .any(.cp(.imm8), argument: 1),
    .any(.jr(.c, .simm8), argument: 2),
  ])

  request.createMacro(named: "ifEq", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .any(.cp(.imm8), argument: 2),
    .any(.jr(.z, .simm8), argument: 3),
  ])

  request.createMacro(named: "ifHEq", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .any(.cp(.imm8), argument: 2),
    .any(.jr(.z, .simm8), argument: 3),
  ])

  request.createMacro(named: "ifHEq_", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .any(.cp(.imm8), argument: 2),
    .any(.jp(.z, .imm16), argument: 3),
  ])

  request.createMacro(named: "ifHNe", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .any(.cp(.imm8), argument: 2),
    .any(.jr(.nz, .simm8), argument: 3),
  ])

  request.createMacro(named: "ifNe", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .any(.cp(.imm8), argument: 2),
    .any(.jr(.nz, .simm8), argument: 3),
  ])

  request.createMacro(named: "ifHNe_", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .any(.cp(.imm8), argument: 2),
    .any(.jp(.nz, .imm16), argument: 3),
  ])

  request.createMacro(named: "_ifNe", pattern: [
    .any(.cp(.imm8), argument: 1),
    .any(.jr(.nz, .simm8), argument: 2),
  ])

  request.createMacro(named: "ifGte", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .any(.cp(.imm8), argument: 2),
    .any(.jr(.nc, .simm8), argument: 3),
  ])

  request.createMacro(named: "returnIfLt", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .any(.cp(.imm8), argument: 2),
    .instruction(.init(spec: .ret(.c))),
  ])

  request.createMacro(named: "returnIfGte", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .any(.cp(.imm8), argument: 2),
    .instruction(.init(spec: .ret(.nc))),
  ])

  request.createMacro(named: "returnIfHLt", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .any(.cp(.imm8), argument: 2),
    .instruction(.init(spec: .ret(.c))),
  ])

  request.createMacro(named: "returnIfHGte", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .any(.cp(.imm8), argument: 2),
    .instruction(.init(spec: .ret(.nc))),
  ])

  request.createMacro(named: "ifLt", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .any(.cp(.imm8), argument: 2),
    .any(.jr(.c, .simm8), argument: 3),
  ])

  request.createMacro(named: "ifNot", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .instruction(.init(spec: .and(.a))),
    .any(.jr(.z, .simm8), argument: 2),
  ])

  request.createMacro(named: "ifNot_", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .instruction(.init(spec: .and(.a))),
    .any(.jp(.z, .imm16), argument: 2),
  ])

  request.createMacro(named: "ifNotH", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .instruction(.init(spec: .and(.a))),
    .any(.jr(.z, .simm8), argument: 2),
  ])

  request.createMacro(named: "ifNotH_", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .instruction(.init(spec: .and(.a))),
    .any(.jp(.z, .imm16), argument: 2),
  ])

  request.createMacro(named: "ifBitsNotSet_", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .any(.and(.imm8), argument: 2),
    .any(.jr(.z, .simm8), argument: 3),
  ])

  request.createMacro(named: "ifBitsNotSetH", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .any(.and(.imm8), argument: 2),
    .any(.jr(.z, .simm8), argument: 3),
  ])

  request.createMacro(named: "_if", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .instruction(.init(spec: .and(.a))),
    .any(.jr(.nz, .simm8), argument: 2),
  ])

  request.createMacro(named: "if_", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .instruction(.init(spec: .and(.a))),
    .any(.jp(.nz, .imm16), argument: 2),
  ])

  request.createMacro(named: "ifH", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .instruction(.init(spec: .and(.a))),
    .any(.jr(.nz, .simm8), argument: 2),
  ])

  request.createMacro(named: "ifH_", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .instruction(.init(spec: .and(.a))),
    .any(.jp(.nz, .imm16), argument: 2),
  ])

  request.createMacro(named: "ifHLAddr", pattern: [
    .instruction(.init(spec: .ld(.a, .hladdr))),
    .instruction(.init(spec: .and(.a))),
    .any(.jr(.nz, .simm8), argument: 1),
  ])

  request.createMacro(named: "ifHLAddr_", pattern: [
    .instruction(.init(spec: .ld(.a, .hladdr))),
    .instruction(.init(spec: .and(.a))),
    .any(.jp(.nz, .imm16), argument: 1),
  ])

  request.createMacro(named: "assignH", pattern: [
    .any(.ld(.a, .imm8), argument: 2),
    .any(.ld(.ffimm8addr, .a), argument: 1),
  ])

  request.createMacro(named: "or__", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .any(.ld(.hl, .imm16), argument: 2),
    .instruction(.init(spec: .or(.hladdr))),
  ])

  request.createMacro(named: "orH_", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .any(.ld(.hl, .imm16), argument: 2),
    .instruction(.init(spec: .or(.hladdr))),
  ])

  request.createMacro(named: "ifAnyH__", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .any(.ld(.hl, .imm16), argument: 2),
    .instruction(.init(spec: .or(.hladdr))),
    .any(.ld(.hl, .imm16), argument: 3),
    .instruction(.init(spec: .or(.hladdr))),
    .any(.jr(.nz, .simm8), argument: 4),
  ])

  request.createMacro(named: "assign", pattern: [
    .any(.ld(.a, .imm8), argument: 2),
    .any(.ld(.imm16addr, .a), argument: 1),
  ])

  request.createMacro(named: "clear", pattern: [
    .instruction(.init(spec: .xor(.a))),
    .any(.ld(.imm16addr, .a), argument: 1),
  ])

  request.createMacro(named: "plusPlusHL", pattern: [
    .any(.ld(.hl, .imm16), argument: 1),
    .instruction(.init(spec: .inc(.hladdr))),
  ])

  request.createMacro(named: "plusEqualH", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .any(.add(.imm8), argument: 2),
    .any(.ld(.ffimm8addr, .a), argument: 1),
  ])

  // TODO: These can't be enabled until we support multiple simultaneous macro checks.
  //      request.createMacro(named: "plusEqual", pattern: [
  //        .any(.ld(.hl, .imm16)),
  //        .any(.ld(.a, .imm16)),
  //        .any(.add(.hladdr)),
  //      ], code: [
  //        .ld(.hl, .arg(2)),
  //        .ld(.a, .arg(1)),
  //        .add(.hladdr),
  //      ])
  //
  //      request.createMacro(named: "plusEqualH", pattern: [
  //        .any(.ld(.hl, .imm16)),
  //        .any(.ld(.a, .ffimm8addr)),
  //        .any(.add(.hladdr)),
  //      ], code: [
  //        .ld(.hl, .arg(2)),
  //        .ld(.a, .arg(1)),
  //        .add(.hladdr),
  //      ])
  //      request.createMacro(named: "_plusEqualH", pattern: [
  //        .any(.ld(.a, .ffimm8addr)),
  //        .any(.ld(.hl, .imm16)),
  //        .any(.add(.hladdr)),
  //        .any(.ld(.ffimm8addr, .a)),
  //      ], code: [
  //        .ld(.a, .arg(1)),
  //        .ld(.hl, .arg(2)),
  //        .add(.hladdr),
  //        .ld(.arg(1), .a)
  //      ])

  request.createMacro(named: "loadHL", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .instruction(.init(spec: .ld(.h, .a))),
    .any(.ld(.a, .imm16addr), argument: 2),
    .instruction(.init(spec: .ld(.l, .a))),
  ])

  request.createMacro(named: "copyMemory", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .any(.ld(.imm16addr, .a), argument: 2),
  ])

  request.createMacro(named: "copyMemoryHH", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .any(.ld(.ffimm8addr, .a), argument: 2),
  ])

  request.createMacro(named: "copyMemory_H", pattern: [
    .any(.ld(.a, .imm16addr), argument: 1),
    .any(.ld(.ffimm8addr, .a), argument: 2),
  ])

  request.createMacro(named: "copyMemoryH_", pattern: [
    .any(.ld(.a, .ffimm8addr), argument: 1),
    .any(.ld(.imm16addr, .a), argument: 2),
  ])

}
