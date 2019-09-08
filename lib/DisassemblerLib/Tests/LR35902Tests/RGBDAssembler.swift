import XCTest
@testable import LR35902

class RGBDAssembler: XCTestCase {
  func test_nop_failsWithExtraOperand() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    nop nop
""")

    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [RGBDSAssembler.Error(lineNumber: 1, error: "Invalid instruction: nop nop")])
  }

  func test_nop_failsWithExtraOperandAtCorrectLine() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """

; This is a comment-only line
    nop nop
""")

    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [RGBDSAssembler.Error(lineNumber: 3, error: "Invalid instruction: nop nop")])
  }

  func test_newline_doesNotCauseParseFailures() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    nop

    nop
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .nop),
      0x0001: LR35902.Instruction(spec: .nop)
    ])
  }

  func test_nop_1() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    nop
""")

    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [0x0000: LR35902.Instruction(spec: .nop)])
  }

  func test_nop_2() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    nop
    nop
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .nop),
      0x0001: LR35902.Instruction(spec: .nop)
    ])
  }

  func test_ld_bc_imm16_dollarHexIsRepresentable() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld bc, $1234
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.bc, .imm16), imm16: 0x1234)
    ])
  }

  func test_ld_bc_imm16_0xHexIsRepresentable() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld bc, 0x1234
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.bc, .imm16), imm16: 0x1234)
    ])
  }

  func test_ld_bc_imm16_numberIsRepresentable() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld bc, 1234
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertTrue(errors.isEmpty)

    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.bc, .imm16), imm16: 1234)
    ])
  }

  func test_ld_bc_imm16_negativeNumberIsRepresentable() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld bc, -1234
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])

    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.bc, .imm16), imm16: UInt16(bitPattern: -1234))
    ])
  }

  func test_ld_bc_imm16_nop() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld bc, $1234
    nop
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.bc, .imm16), imm16: 0x1234),
      0x0003: LR35902.Instruction(spec: .nop)
    ])
  }

  func test_ld_bc_imm16_unrepresentableNumberFails() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld bc, $12342342342
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [RGBDSAssembler.Error(lineNumber: 1, error: "Unable to represent $12342342342 as a UInt16")])
    XCTAssertEqual(disassembly.instructionMap, [:])
  }

  func test_ld_bc_imm16_emptyNumberFails() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld bc, $
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [RGBDSAssembler.Error(lineNumber: 1, error: "Unable to represent $ as a UInt16")])
    XCTAssertEqual(disassembly.instructionMap, [:])
  }

  func test_ld_bcAddress_a() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld [bc], a
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.bcaddr, .a)),
    ])
  }

  func test_inc_bc() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    inc bc
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .inc(.bc)),
    ])
  }

  func test_ld_b_imm8() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld b, 255
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.b, .imm8), imm8: 255),
    ])
  }

  func test_ld_b_imm8_0xHex() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld b, 0xFF
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.b, .imm8), imm8: 255),
    ])
  }

  func test_ld_imm16addr_sp() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld [$1234], sp
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.imm16addr, .sp), imm16: 0x1234),
    ])
  }

  func test_ld_a_bcaddr() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld a, [bc]
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.a, .bcaddr)),
    ])
  }

  func test_rrca() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    rrca
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .rrca),
    ])
  }

  func test_jr() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    jr 5
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .jr(nil, .simm8), imm8: 3),
    ])
  }

  func test_ld_ffimm8_a() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld [$FFA0], a
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.ffimm8addr, .a), imm8: 0xA0),
    ])
  }

  func test_ld_imm16_a() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld [$FAA0], a
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.imm16addr, .a), imm16: 0xFAA0),
    ])
  }

  func test_ret_z() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ret z
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ret(.z)),
    ])
  }

  func test_sub_imm8() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    sub 5
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .sub(.imm8), imm8: 5),
    ])
  }

  func test_rst() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    rst $38
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .rst(.x38)),
    ])
  }

  func test_rlc_b() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    rlc b
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .cb(.rlc(.b))),
    ])
  }

  func test_bit_2_b() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    bit 2, b
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .cb(.bit(.b2, .b))),
    ])
  }

  func test_set_6_hladdr() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    set 6, [hl]
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .cb(.set(.b6, .hladdr))),
    ])
  }

  func test_jr_cond() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    jr nz, 5
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .jr(.nz, .simm8), imm8: 3),
    ])
  }

  func test_ld_hl_spimm8() throws {
    let assembler = RGBDSAssembler()
    let errors = assembler.assemble(assembly: """
    ld hl, sp+$05
""")
    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

    XCTAssertEqual(errors, [])
    XCTAssertEqual(disassembly.instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.hl, .sp_plus_simm8), imm8: 0x05),
    ])
  }

  func test_allInstructions() throws {
    for spec in LR35902.Instruction.table {
      guard spec != .invalid else {
        continue
      }
      if case .cb = spec {
        continue
      }
      let representation = spec.representation

      let assembly: String
      switch spec {
      case .ld(.ffimm8addr, _), .ld(_, .ffimm8addr):
        assembly = representation.replacingOccurrences(of: "#", with: "$FF00")
      case let .rst(address):
        assembly = representation.replacingOccurrences(of: "#", with: "\(address.rawValue)")
      default:
        assembly = representation.replacingOccurrences(of: "#", with: "0")
      }

      let assembler = RGBDSAssembler()
      let errors = assembler.assemble(assembly: assembly)
      let disassembly = LR35902.Disassembly(rom: assembler.buffer)
      disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

      XCTAssertEqual(errors, [], "Spec: \(spec)")
      XCTAssertEqual(disassembly.instructionMap[0x0000]?.spec, spec)
    }

    for spec in LR35902.Instruction.tableCB {
      guard spec != .invalid else {
        continue
      }
      let representation = spec.representation

      let assembly: String
      switch spec {
      case .ld(.ffimm8addr, _), .ld(_, .ffimm8addr):
        assembly = representation.replacingOccurrences(of: "#", with: "$FF00")
      case let .rst(address):
        assembly = representation.replacingOccurrences(of: "#", with: "\(address.rawValue)")
      case let .cb(.bit(bit, _)), let .cb(.res(bit, _)), let .cb(.set(bit, _)):
        assembly = representation.replacingOccurrences(of: "#", with: "\(bit.rawValue)")
      default:
        assembly = representation.replacingOccurrences(of: "#", with: "0")
      }

      let assembler = RGBDSAssembler()
      let errors = assembler.assemble(assembly: assembly)
      let disassembly = LR35902.Disassembly(rom: assembler.buffer)
      disassembly.disassemble(range: 0..<UInt16(assembler.buffer.count), inBank: 0x00)

      XCTAssertEqual(errors, [], "Spec: \(spec)")
      XCTAssertEqual(disassembly.instructionMap[0x0000]?.spec, spec)
    }
  }

  func testBoo() {
    let assembler = RGBDSAssembler()
    let _ = assembler.assemble(assembly: """
   ld   c, a                                    ; $282A (00): ReadJoypadState $4F
   ld   a, [$ffcb]               ; $282B (00): ReadJoypadState $F0 $CB
   xor  c                                       ; $282D (00): ReadJoypadState $A9
   and  c                                       ; $282E (00): ReadJoypadState $A1
   ld   [$ffcc], a                       ; $282F (00): ReadJoypadState $E0 $CC
   ld   a, c                                    ; $2831 (00): ReadJoypadState $79
   ld   [$ffcb], a               ; $2832 (00): ReadJoypadState $E0 $CB
""")

    let disassembly = LR35902.Disassembly(rom: assembler.buffer)
    disassembly.disassemble(range: 0..<LR35902.Address(assembler.buffer.count), inBank: 0x00)

    var initialState = LR35902.Disassembly.CPUState()

    initialState.a = LR35902.Disassembly.CPUState.RegisterState<UInt8>(value: .value(0b0000_1111), sourceLocation: 0)
    initialState.ram[0xffcb] = .init(value: .value(0b0000_1100), sourceLocation: 0)

    let states = disassembly.simulate(range: 0..<LR35902.CartridgeLocation(assembler.buffer.count),
                                      initialState: initialState).sorted(by: { $0.key < $1.key })
    let lastState = states[states.count - 1]

    XCTAssertEqual(lastState.value.a, .init(value: .value(0b0000_1111), sourceLocation: 0))
    XCTAssertEqual(lastState.value.c, .init(value: .value(0b0000_1111), sourceLocation: 0))
    XCTAssertEqual(lastState.value.ram[0xffcb], .init(value: .value(0b0000_1111), sourceLocation: 0))
    XCTAssertEqual(lastState.value.ram[0xffcc], .init(value: .value(0b0000_0011), sourceLocation: 4))
  }
}