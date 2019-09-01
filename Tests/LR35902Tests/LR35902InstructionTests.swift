import XCTest
@testable import LR35902

final class LR35902InstructionTests: XCTestCase {

  func test_nop() throws {
    let data = Data([0])
    let disassembly = LR35902.Disassembly(rom: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    let instruction = disassembly.instruction(at: 0x0000, in: 0x00)!
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .nop))
  }

  func test_ld_bc_imm16() throws {
    let data = Data([0x01, 0x12, 0x34])
    let disassembly = LR35902.Disassembly(rom: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    let instruction = disassembly.instruction(at: 0x0000, in: 0x00)!
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .ld(.bc, .imm16), imm16: 0x3412))
  }

  func test_ld_bcadd_a() throws {
    let data = Data([0x02])
    let disassembly = LR35902.Disassembly(rom: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    let instruction = disassembly.instruction(at: 0x0000, in: 0x00)!
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .ld(.bcaddr, .a)))
  }

  func test_inc_bc() throws {
    let data = Data([0x03])
    let disassembly = LR35902.Disassembly(rom: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    let instruction = disassembly.instruction(at: 0x0000, in: 0x00)!
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .inc(.bc)))
  }

  func test_inc_b() throws {
    let data = Data([0x04])
    let disassembly = LR35902.Disassembly(rom: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    let instruction = disassembly.instruction(at: 0x0000, in: 0x00)!
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .inc(.b)))
  }

  func test_dec_b() throws {
    let data = Data([0x05])
    let disassembly = LR35902.Disassembly(rom: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x00)

    let instruction = disassembly.instruction(at: 0x0000, in: 0x00)!
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .dec(.b)))
  }
}

