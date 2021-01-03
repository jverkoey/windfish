import XCTest
@testable import Windfish

extension Disassembler.Macro: Equatable {
  public static func == (lhs: Disassembler.Macro, rhs: Disassembler.Macro) -> Bool {
    return lhs.name == rhs.name && lhs.validArgumentValues == rhs.validArgumentValues && lhs.macroLines == rhs.macroLines
  }
}

extension Disassembler.MacroNode: Equatable {
  public static func == (lhs: Disassembler.MacroNode, rhs: Disassembler.MacroNode) -> Bool {
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

    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)

    let disassembly = Disassembler(data: data)

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
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

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
        Disassembler.Line(semantic: .section(0), address: nil, bank: nil, scope: nil, data: nil),
        Disassembler.Line(semantic: .empty, address: nil, bank: nil, scope: nil, data: nil),
        Disassembler.Line(semantic: .instruction(.init(spec: .ld(.a, .imm8), immediate: .imm8(68)),
                                                        .init(opcode: "ld", operands: ["a", "STATF_LYC | STATF_LYCF"])),
                                 address: 0, bank: 0x01, scope: "", data: Data([0x3e, 0x44])),
        Disassembler.Line(semantic: .instruction(.init(spec: .ld(.ffimm8addr, .a), immediate: .imm8(65)),
                                                        .init(opcode: "ld", operands: ["[gbSTAT]", "a"])),
                                 address: 2, bank: 0x01, scope: "", data: Data([0xe0, 0x41]))
      ])
    }
  }

  func testAmbiguousMacro() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld   a, [$abcd]
and  a
jr   z, @-$03
""")
    XCTAssertEqual(results.errors, [])

    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)

    let disassembly = Disassembler(data: data)

    disassembly.defineMacro(named: "macro", template: """
ld   a, [#1]
and  a
jr   z, #2
""")
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    let tree = Disassembler.MacroNode(
      children: [
        .arg(.ld(.a, .imm16addr)): Disassembler.MacroNode(
          children: [
            .instruction(.init(spec: .and(.a))): Disassembler.MacroNode(
              children: [
                .arg(.jr(.z, .simm8)): Disassembler.MacroNode(
                  children: [:],
                  macros: [
                    .init(
                      name: "macro",
                      macroLines: [
                        .arg(.ld(.a, .imm16addr), argument: 1),
                        .instruction(.init(spec: .and(.a))),
                        .arg(.jr(.z, .simm8), argument: 2),
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
        ),
        .arg(.ld(.a, .ffimm8addr)): Disassembler.MacroNode(
          children: [
            .instruction(.init(spec: .and(.a))): Disassembler.MacroNode(
              children: [
                .arg(.jr(.z, .simm8)): Disassembler.MacroNode(
                  children: [:],
                  macros: [
                    .init(
                      name: "macro",
                      macroLines: [
                        .arg(.ld(.a, .ffimm8addr), argument: 1),
                        .instruction(.init(spec: .and(.a))),
                        .arg(.jr(.z, .simm8), argument: 2),
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
        )
      ],
      macros: []
    )
    XCTAssertEqual(disassembly.macroTree, tree)

    let (source, _) = try! disassembly.generateSource()
    let bank00Source = source.sources["bank_00.asm"]
    if case let .bank(bank, content, _) = bank00Source {
      XCTAssertEqual(bank, 0)
      XCTAssertEqual(content, """
SECTION "ROM Bank 00", ROM0[$00]

    macro [$ABCD], @-$03

""")
    }
  }

  func test_somethingelse() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld   hl, $44
inc  [hl]
""")
    XCTAssertEqual(results.errors, [])

    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)

    let disassembly = Disassembler(data: data)

    disassembly.defineMacro(named: "plusPlusHL", template: """
ld hl, #1
inc [hl]
""")
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    XCTAssertEqual(disassembly.macroTree, Disassembler.MacroNode(
      children: [
        .arg(.ld(.hl, .imm16)): Disassembler.MacroNode(
          children: [
            .instruction(.init(spec: .inc(.hladdr))): Disassembler.MacroNode(
              children: [:],
              macros: [
                .init(
                  name: "plusPlusHL",
                  macroLines: [
                    .arg(.ld(.hl, .imm16), argument: 1),
                    .instruction(.init(spec: .inc(.hladdr)))
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

    let (source, _) = try! disassembly.generateSource()
    let bank00Source = source.sources["bank_00.asm"]
    if case let .bank(bank, content, _) = bank00Source {
      XCTAssertEqual(bank, 0)
      XCTAssertEqual(content, """
SECTION "ROM Bank 00", ROM0[$00]

    plusPlusHL $0044
""")
    }
  }

  func test_nop() {
    let results = RGBDSAssembler.assemble(assembly: """
nop
""")
    XCTAssertEqual(results.errors, [])

    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)

    let disassembly = Disassembler(data: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    let (source, _) = try! disassembly.generateSource()
    let bank00Source = source.sources["bank_00.asm"]
    if case let .bank(bank, content, _) = bank00Source {
      XCTAssertEqual(bank, 0)
      XCTAssertEqual(content, """
SECTION "ROM Bank 00", ROM0[$00]

    nop
""")
    }
  }

  func test_ld_imm16addr_a() {
    let results = RGBDSAssembler.assemble(assembly: """
ld [$abcd], a
""")
    XCTAssertEqual(results.errors, [])

    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)

    let disassembly = Disassembler(data: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    let (source, _) = try! disassembly.generateSource()
    let bank00Source = source.sources["bank_00.asm"]
    if case let .bank(bank, content, _) = bank00Source {
      XCTAssertEqual(bank, 0)
      XCTAssertEqual(content, """
SECTION "ROM Bank 00", ROM0[$00]

    ld   [$ABCD], a
""")
    }
  }

  func test_jr_simm8() {
    let results = RGBDSAssembler.assemble(assembly: """
nop
jr @-$01
""")
    XCTAssertEqual(results.errors, [])

    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)

    let disassembly = Disassembler(data: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    let (source, _) = try! disassembly.generateSource()
    let bank00Source = source.sources["bank_00.asm"]
    if case let .bank(bank, content, _) = bank00Source {
      XCTAssertEqual(bank, 0)
      XCTAssertEqual(content, """
SECTION "ROM Bank 00", ROM0[$00]

toc_01_0000:
    nop
    jr   toc_01_0000

""")
    }
  }

  func test_somethingelse3() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld   a, 1
ld   [$2100], a
call $4100
""")
    XCTAssertEqual(results.errors, [])

    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)

    let disassembly = Disassembler(data: data)

    disassembly.defineMacro(named: "callcb", instructions: [
      .arg(.ld(.a, .imm8), argumentText: "bank(\\1)"),
      .instruction(.init(spec: .ld(.imm16addr, .a), immediate: .imm16(0x2100))),
      .arg(.call(nil, .imm16), argument: 1)
    ], validArgumentValues: [
      1: IndexSet(integersIn: 0x4000..<0x8000)
    ])
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    XCTAssertEqual(disassembly.macroTree, Disassembler.MacroNode(
      children: [
        .arg(.ld(.a, .imm8)): Disassembler.MacroNode(
          children: [
            .instruction(.init(spec: .ld(.imm16addr, .a), immediate: .imm16(0x2100))): Disassembler.MacroNode(
              children: [
                .arg(.call(nil, .imm16)): Disassembler.MacroNode(
                  children: [:],
                  macros:[
                    .init(
                      name: "callcb",
                      macroLines: [
                        .arg(.ld(.a, .imm8), argumentText: "bank(\\1)"),
                        .instruction(.init(spec: .ld(.imm16addr, .a), immediate: .imm16(0x2100))),
                        .arg(.call(nil, .imm16), argument: 1)
                      ],
                      validArgumentValues: [
                        1: IndexSet(integersIn: 0x4000..<0x8000)
                      ],
                      action: nil
                    )
                  ]
                )
              ]
            )
          ],
          macros: []
        )
      ],
      macros: []
    ))

    let (source, _) = try! disassembly.generateSource()
    let bank00Source = source.sources["bank_00.asm"]
    if case let .bank(bank, content, _) = bank00Source {
      XCTAssertEqual(bank, 0)
      XCTAssertEqual(content, """
SECTION "ROM Bank 00", ROM0[$00]

    callcb toc_01_4100
""")
    }

    let macrosSource = source.sources["macros.asm"]
    if case let .macros(content) = macrosSource {
      XCTAssertEqual(content, """

; Arguments:
; - 1 type: nil: valid values in $4000..<$8000
callcb: MACRO
    ld   a, bank(\\1)
    ld   [$2100], a
    call \\1
    ENDM
""")
    }
  }
}
