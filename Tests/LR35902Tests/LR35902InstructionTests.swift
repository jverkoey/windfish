import XCTest
@testable import LR35902

final class LR35902InstructionTests: XCTestCase {

  func test_nop() throws {
    let data = Data([0])
    let disassembly = LR35902.Disassembly(rom: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    let instruction = try XCTUnwrap(disassembly.instruction(at: 0x0000, in: 0x00))
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .nop))
  }

  func test_ld_bc_imm16() throws {
    let data = Data([0x01, 0x12, 0x34])
    let disassembly = LR35902.Disassembly(rom: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    let instruction = try XCTUnwrap(disassembly.instruction(at: 0x0000, in: 0x00))
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .ld(.bc, .immediate16), immediate16: 0x3412))
  }

  func test_ld_bcAdd_a() throws {
    let data = Data([0x02])
    let disassembly = LR35902.Disassembly(rom: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    let instruction = try XCTUnwrap(disassembly.instruction(at: 0x0000, in: 0x00))
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .ld(.bcAddress, .a)))
  }
}

