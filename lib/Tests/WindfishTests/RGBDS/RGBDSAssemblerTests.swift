import XCTest

@testable import Windfish

class RGBDSAssemblerTests: XCTestCase {
  func test_nop_failsWithExtraOperand() throws {
    let results = RGBDSAssembler.assemble(assembly: """
nop nop
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)

    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [RGBDSAssembler.Error(lineNumber: 1, message: "No valid instruction found for nop  nop")])
  }

  func test_nop_failsWithExtraOperandAtCorrectLine() throws {
    let results = RGBDSAssembler.assemble(assembly: """

; This is a comment-only line
nop nop
""")

    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)

    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [RGBDSAssembler.Error(lineNumber: 3, message: "No valid instruction found for nop  nop")])
  }

  func test_newline_doesNotCauseParseFailures() throws {
    let results = RGBDSAssembler.assemble(assembly: """
nop

nop
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .nop),
      0x0001: LR35902.Instruction(spec: .nop)
    ])
  }

  func test_nop_1() throws {
    let results = RGBDSAssembler.assemble(assembly: """
nop
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)

    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [0x0000: LR35902.Instruction(spec: .nop)])
  }

  func test_nop_2() throws {
    let results = RGBDSAssembler.assemble(assembly: """
nop
nop
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .nop),
      0x0001: LR35902.Instruction(spec: .nop)
    ])
  }

  func test_ld_bc_imm16_dollarHexIsRepresentable() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld bc, $1234
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.bc, .imm16), immediate: .imm16(0x1234))
    ])
  }

  func test_ld_bc_imm16_0xHexIsNotRepresentable() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld bc, 0x1234
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    XCTAssertTrue(data.isEmpty)
  }

  func test_ld_bc_imm16_numberIsRepresentable() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld bc, 1234
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertTrue(results.errors.isEmpty)

    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.bc, .imm16), immediate: .imm16(1234))
    ])
  }

  func test_ld_bc_imm16_negativeNumberIsRepresentable() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld bc, -1234
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])

    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.bc, .imm16), immediate: .imm16(UInt16(bitPattern: -1234)))
    ])
  }

  func test_ld_bc_imm16_nop() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld bc, $1234
    nop
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.bc, .imm16), immediate: .imm16(0x1234)),
      0x0003: LR35902.Instruction(spec: .nop)
    ])
  }

  func test_ld_bc_imm16_unrepresentableNumberFails() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld bc, $12342342342
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    XCTAssertTrue(data.isEmpty)
  }

  func test_ld_bc_imm16_emptyNumberFails() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld bc, $
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    XCTAssertTrue(data.isEmpty)
  }

  func test_ld_bcAddress_a() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld [bc], a
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.bcaddr, .a)),
    ])
  }

  func test_inc_bc() throws {
    let results = RGBDSAssembler.assemble(assembly: """
inc bc
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .inc(.bc)),
    ])
  }

  func test_ld_b_imm8() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld b, 255
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.b, .imm8), immediate: .imm8(255)),
    ])
  }

  func test_ld_b_imm8_0xHexIsNotSupported() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld b, 0xFF
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    XCTAssertTrue(data.isEmpty)
  }

  func test_ld_imm16addr_sp() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld [$1234], sp
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.imm16addr, .sp), immediate: .imm16(0x1234)),
    ])
  }

  func test_ld_a_bcaddr() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld a, [bc]
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.a, .bcaddr)),
    ])
  }

  func test_rrca() throws {
    let results = RGBDSAssembler.assemble(assembly: """
rrca
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .rrca),
    ])
  }

  func test_jr() throws {
    let results = RGBDSAssembler.assemble(assembly: """
jr 5
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .jr(nil, .simm8), immediate: .imm8(5)),
    ])
  }

  func test_ld_ffimm8_a() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld [$FFA0], a
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.ffimm8addr, .a), immediate: .imm8(0xA0)),
    ])
  }

  func test_ld_imm16_a() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld [$FAA0], a
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.imm16addr, .a), immediate: .imm16(0xFAA0)),
    ])
  }

  func test_ret_z() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ret z
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .ret(.z)),
    ])
  }

  func test_sub_imm8() throws {
    let results = RGBDSAssembler.assemble(assembly: """
sub a, 5
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .sub(.a, .imm8), immediate: .imm8(5)),
    ])
  }

  func test_rst() throws {
    let results = RGBDSAssembler.assemble(assembly: """
rst $38
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .rst(.x38)),
    ])
  }

  func test_rlc_b() throws {
    let results = RGBDSAssembler.assemble(assembly: """
rlc b
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .cb(.rlc(.b))),
    ])
  }

  func test_bit_2_b() throws {
    let results = RGBDSAssembler.assemble(assembly: """
bit 2, b
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .cb(.bit(.b2, .b))),
    ])
  }

  func test_set_6_hladdr() throws {
    let results = RGBDSAssembler.assemble(assembly: """
set 6, [hl]
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .cb(.set(.b6, .hladdr))),
    ])
  }

  func test_jr_cond() throws {
    let results = RGBDSAssembler.assemble(assembly: """
jr nz, 3
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .jr(.nz, .simm8), immediate: .imm8(3)),
    ])
  }

  func test_ld_hl_spimm8() throws {
    let results = RGBDSAssembler.assemble(assembly: """
ld hl, sp+$05
""")
    let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
    let disassembly = Disassembler(data: data)
    disassembly.willStart()
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    XCTAssertEqual(results.errors, [])
    XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap, [
      0x0000: LR35902.Instruction(spec: .ld(.hl, .sp_plus_simm8), immediate: .imm8(0x05)),
    ])
  }

  func testAssemblyAndDisassemblyIsEqual() throws {
    for spec in LR35902.InstructionSet.allSpecs() {
      guard spec != .invalid else {
        continue
      }
      if case .prefix = spec {
        continue
      }
      let representation = LR35902.InstructionSet.specToTokenString[spec]!

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

      let results = RGBDSAssembler.assemble(assembly: assembly)
      let data = results.instructions.map { LR35902.InstructionSet.data(representing: $0) }.reduce(Data(), +)
      let disassembly = Disassembler(data: data)
      disassembly.willStart()
      disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

      XCTAssertEqual(results.errors, [], "Spec: \(spec)")
      XCTAssertEqual(disassembly.lastBankRouter!.bankWorkers[0].instructionMap[0]?.spec, spec)
    }
  }
}
