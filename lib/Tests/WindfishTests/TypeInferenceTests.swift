import XCTest
@testable import Windfish

extension Disassembler.Configuration.Macro: Equatable {
  public static func == (lhs: Disassembler.Configuration.Macro, rhs: Disassembler.Configuration.Macro) -> Bool {
    return lhs.name == rhs.name && lhs.validArgumentValues == rhs.validArgumentValues && lhs.macroLines == rhs.macroLines
  }
}

extension Disassembler.Configuration.MacroNode: Equatable {
  public static func == (lhs: Disassembler.Configuration.MacroNode, rhs: Disassembler.Configuration.MacroNode) -> Bool {
    return lhs.macros == rhs.macros && lhs.children == rhs.children
  }

}

class TypeInferenceTests: XCTestCase {
  func test_LinksAwakening_01_4219_ff9d_does_not_back_propagate_to_and_3f() throws {
    let results = RGBDSAssembler.assemble(assembly: """
    rra
    rra
    rra
    and  $3f
    ld   e, a
    ld   d, $00
    ld   hl, $4191
    add  hl, de
    ld   a, [hl]
    ld   [$ff9d], a
    ld   a, [$FFB7]
""")
    XCTAssertEqual(results.errors, [])

    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)

    let disassembly = Disassembler(data: data)

    disassembly.willStart()
    disassembly.mutableConfiguration.createDatatype(named: "LINK_ANIMATION", bitmask: [
      0x3f: "LINK_ANIMATION_STATE_WALKING_LIFTING_RIGHT",
    ])
    disassembly.mutableConfiguration.registerGlobal(at: 0xff9d, named: "hLinkAnimationState", dataType: "LINK_ANIMATION")
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    let (source, _) = try! disassembly.generateSource()
    let bank00Source = source.sources["bank_00.asm"]
    if case let .bank(bank, content, _) = bank00Source {
      XCTAssertEqual(bank, 0)

      XCTAssertEqual(content, """
SECTION "ROM Bank 00", ROM0[$00]

    rra
    rra
    rra
    and  %00111111
    ld   e, a
    ld   d, $00
    ld   hl, $4191
    add  hl, de
    ld   a, [hl]
    ld   [hLinkAnimationState], a
    ld   a, [$FFB7]
""")
    }
  }

  func test_LinksAwakening_00_0AB6() throws {
    let results = RGBDSAssembler.assemble(assembly: """
    ld   a, [$c19f]
    ld   hl, $C167
    or   [hl]
    ld   hl, $C124
    or   [hl]
    jr   nz, $18

    ld   a, [$FFCB]
    cp   $F0
    jr   nz, $12
    xor  a
    ld   [$C16B], a
    ld   [$C16C], a
    ld   [$c19f], a
    ld   [$DB96], a
    ld   a, $06
    ld   [$95db], a
    ld   a, [$95db]
    rst  $00
""")
    XCTAssertEqual(results.errors, [])

    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)

    let disassembly = Disassembler(data: data)

    disassembly.willStart()
    disassembly.mutableConfiguration.createDatatype(named: "binary", bitmask: [:], representation: .binary)
    disassembly.mutableConfiguration.createDatatype(named: "BUTTON", bitmask: [
      0b00000001: "J_RIGHT",
      0b00000010: "J_LEFT",
      0b00000100: "J_UP",
      0b00001000: "J_DOWN",
      0b00010000: "J_A",
      0b00100000: "J_B",
      0b01000000: "J_SELECT",
      0b10000000: "J_START",
    ])
    disassembly.mutableConfiguration.registerGlobal(at: 0xffcb, named: "hPressedButtonsMask", dataType: "BUTTON")
    disassembly.mutableConfiguration.registerGlobal(at: 0xc19f, named: "wDialogState", dataType: "binary")
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    let (source, _) = try! disassembly.generateSource()
    let bank00Source = source.sources["bank_00.asm"]
    if case let .bank(bank, content, _) = bank00Source {
      XCTAssertEqual(bank, 0)

      XCTAssertEqual(content, """
SECTION "ROM Bank 00", ROM0[$00]

    ld   a, [wDialogState]
    ld   hl, $C167
    or   [hl]
    ld   hl, $C124
    or   [hl]
    jr   nz, else_01_0025

    ld   a, [hPressedButtonsMask]
    cp   J_A | J_B | J_SELECT | J_START
    jr   nz, else_01_0025

    xor  a
    ld   [$C16B], a
    ld   [$C16C], a
    ld   [wDialogState], a
    ld   [$DB96], a
    ld   a, $06
    ld   [$95DB], a
else_01_0025:
    ld   a, [$95DB]
    rst  $00
""")
    }
  }

  func test_something() throws {
   let results = RGBDSAssembler.assemble(assembly: """
   ld   a, $44
   ld   [$ff41], a
""")
    XCTAssertEqual(results.errors, [])

    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)

    let disassembly = Disassembler(data: data)

    disassembly.willStart()
    disassembly.mutableConfiguration.createDatatype(named: "STATF", bitmask: [
      0b0100_0000: "STATF_LYC",
      0b0010_0000: "STATF_MODE10",
      0b0001_0000: "STATF_MODE01",
      0b0000_1000: "STATF_MODE00",
      0b0000_0100: "STATF_LYCF",
      0b0000_0010: "STATF_OAM",
      0b0000_0001: "STATF_VB",
      0b0000_0000: "STATF_HB"
    ])
    disassembly.mutableConfiguration.registerGlobal(at: 0xff41, named: "gbSTAT", dataType: "STATF")
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

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

    disassembly.mutableConfiguration.registerMacro(named: "macro", template: """
ld   a, [#1]
and  a
jr   z, #2
""")
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    let tree = Disassembler.Configuration.MacroNode(
      children: [
        .arg(.ld(.a, .imm16addr)): Disassembler.Configuration.MacroNode(
          children: [
            .instruction(.init(spec: .and(.a))): Disassembler.Configuration.MacroNode(
              children: [
                .arg(.jr(.z, .simm8)): Disassembler.Configuration.MacroNode(
                  children: [:],
                  macros: [
                    .init(
                      name: "macro",
                      macroLines: [
                        .arg(spec: .ld(.a, .imm16addr), argument: 1),
                        .instruction(.init(spec: .and(.a))),
                        .arg(spec: .jr(.z, .simm8), argument: 2),
                      ],
                      validArgumentValues: nil
                    )
                  ]
                )
              ],
              macros: []
            )
          ],
          macros: []
        ),
        .arg(.ld(.a, .ffimm8addr)): Disassembler.Configuration.MacroNode(
          children: [
            .instruction(.init(spec: .and(.a))): Disassembler.Configuration.MacroNode(
              children: [
                .arg(.jr(.z, .simm8)): Disassembler.Configuration.MacroNode(
                  children: [:],
                  macros: [
                    .init(
                      name: "macro",
                      macroLines: [
                        .arg(spec: .ld(.a, .ffimm8addr), argument: 1),
                        .instruction(.init(spec: .and(.a))),
                        .arg(spec: .jr(.z, .simm8), argument: 2),
                      ],
                      validArgumentValues: nil
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
    XCTAssertEqual(disassembly.configuration.macroTreeRoot(), tree)

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

    disassembly.mutableConfiguration.registerMacro(named: "plusPlusHL", template: """
ld hl, #1
inc [hl]
""")
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(disassembly.configuration.macroTreeRoot(), Disassembler.Configuration.MacroNode(
      children: [
        .arg(.ld(.hl, .imm16)): Disassembler.Configuration.MacroNode(
          children: [
            .instruction(.init(spec: .inc(.hladdr))): Disassembler.Configuration.MacroNode(
              children: [:],
              macros: [
                .init(
                  name: "plusPlusHL",
                  macroLines: [
                    .arg(spec: .ld(.hl, .imm16), argument: 1),
                    .instruction(.init(spec: .inc(.hladdr)))
                  ],
                  validArgumentValues: nil
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
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

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
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

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
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

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

    disassembly.mutableConfiguration.registerMacro(named: "callcb", template: """
ld a, bank(#1)
ld [$2100], a
call #1
""", validArgumentValues: [
  1: IndexSet(integersIn: 0x4000..<0x8000)
])
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(disassembly.configuration.macroTreeRoot(), Disassembler.Configuration.MacroNode(
      children: [
        .arg(.ld(.a, .imm8)): Disassembler.Configuration.MacroNode(
          children: [
            .instruction(.init(spec: .ld(.imm16addr, .a), immediate: .imm16(0x2100))): Disassembler.Configuration.MacroNode(
              children: [
                .arg(.call(nil, .imm16)): Disassembler.Configuration.MacroNode(
                  children: [:],
                  macros:[
                    .init(
                      name: "callcb",
                      macroLines: [
                        .arg(spec: .ld(.a, .imm8), argumentText: "bank(\\1)"),
                        .instruction(.init(spec: .ld(.imm16addr, .a), immediate: .imm16(0x2100))),
                        .arg(spec: .call(nil, .imm16), argument: 1)
                      ],
                      validArgumentValues: [
                        1: IndexSet(integersIn: 0x4000..<0x8000)
                      ]
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

    callcb $4100
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
