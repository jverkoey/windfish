import XCTest
@testable import LR35902

extension LR35902.Disassembly.Macro: Equatable {
  public static func == (lhs: LR35902.Disassembly.Macro, rhs: LR35902.Disassembly.Macro) -> Bool {
    return lhs.name == rhs.name && lhs.validArgumentValues == rhs.validArgumentValues && lhs.macroLines == rhs.macroLines
  }
}

extension LR35902.Disassembly.MacroNode: Equatable {
  public static func == (lhs: LR35902.Disassembly.MacroNode, rhs: LR35902.Disassembly.MacroNode) -> Bool {
    return lhs.macros == rhs.macros && lhs.children == rhs.children
  }

}

class TypeInferenceTests: XCTestCase {
  func test_something() throws {
   let results = RGBDSAssembler.assemble(assembly: """
   ld   a, $44
   ld   [$ff41], a
""")
    XCTAssertEqual(results.errors, [])

    let disassembly = LR35902.Disassembly(rom: results.data)

    disassembly.createDatatype(named: "STATF", bitmask: [
      0b0100_0000: "STATF_LYC",
      0b0010_0000: "STATF_MODE10",
      0b0001_0000: "STATF_MODE01",
      0b0000_1000: "STATF_MODE00",
      0b0000_0100: "STATF_LYCF",
      0b0000_0010: "STATF_OAM",
      0b0000_0001: "STATF_VB",
      0b0000_0000: "STATF_HB"
    ])
    disassembly.createGlobal(at: 0xff41, named: "gbSTAT", dataType: "STATF")
    disassembly.disassemble(range: 0..<UInt16(results.data.count), inBank: 0x00)

    let (source, _) = try! disassembly.generateSource()
    let bank00Source = source.sources["bank_00.asm"]
    if case let .bank(bank, content, lines) = bank00Source {
      XCTAssertEqual(bank, 0)
      XCTAssertEqual(content, """
SECTION "ROM Bank 00", ROM0[$00]

    ld   a, STATF_LYC | STATF_LYCF
    ld   [gbSTAT], a
""")
      XCTAssertEqual(lines, [
        LR35902.Disassembly.Line(semantic: .section(0), address: nil, bank: nil, scope: nil, data: nil),
        LR35902.Disassembly.Line(semantic: .empty, address: nil, bank: nil, scope: nil, data: nil),
        LR35902.Disassembly.Line(semantic: .instruction(.init(spec: .ld(.a, .imm8), immediate: .imm8(68)),
                                                        .init(opcode: "ld", operands: ["a", "STATF_LYC | STATF_LYCF"])),
                                 address: 0, bank: 0, scope: "", data: Data([0x3e, 0x44])),
        LR35902.Disassembly.Line(semantic: .instruction(.init(spec: .ld(.ffimm8addr, .a), immediate: .imm8(65)),
                                                        .init(opcode: "ld", operands: ["[gbSTAT]", "a"])),
                                 address: 2, bank: 0, scope: "", data: Data([0xe0, 0x41]))
      ])
    }
  }

  func test_somethingelse() throws {
    let disassembly = LR35902.Disassembly(rom: Data())

    disassembly.defineMacro(named: "assign", template: """
ld a, #2
ld [#1], a
""")

    XCTAssertEqual(disassembly.macroTree, LR35902.Disassembly.MacroNode(
      children: [
        .any(.ld(.a, .imm8)): LR35902.Disassembly.MacroNode(
          children: [
            .any(.ld(.imm16addr, .a)): LR35902.Disassembly.MacroNode(
              children: [:],
              macros: [
                .init(
                  name: "assign",
                  macroLines: [
                    .any(.ld(.a, .imm8), argument: 2),
                    .any(.ld(.imm16addr, .a), argument: 1)
                  ],
                  validArgumentValues: nil,
                  action: nil
                )
              ]
            )
          ],
          macros: []
        )
      ],
      macros: []
    ))
  }
}
