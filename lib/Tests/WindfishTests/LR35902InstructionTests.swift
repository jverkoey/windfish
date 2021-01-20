import XCTest
@testable import Windfish

extension Disassembler {
  // Short-hand notation for disassembling a region
  func disassemble(range: Range<LR35902.Address>, inBank bank: Cartridge.Bank) {
    registerExecutableRegion(at: range, in: bank)
    disassemble()
  }
}

final class LR35902InstructionTests: XCTestCase {

  func test_nop() throws {
    let data = Data([0])
    let disassembly = Disassembler(data: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    let instruction = disassembly.instruction(at: 0x0000, in: 0x01)!
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .nop))
  }

  func test_ld_bc_imm16() throws {
    let data = Data([0x01, 0x12, 0x34])
    let disassembly = Disassembler(data: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    let instruction = disassembly.instruction(at: 0x0000, in: 0x01)!
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .ld(.bc, .imm16), immediate: .imm16(0x3412)))
  }

  func test_ld_bcadd_a() throws {
    let data = Data([0x02])
    let disassembly = Disassembler(data: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    let instruction = disassembly.instruction(at: 0x0000, in: 0x01)!
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .ld(.bcaddr, .a)))
  }

  func test_inc_bc() throws {
    let data = Data([0x03])
    let disassembly = Disassembler(data: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    let instruction = disassembly.instruction(at: 0x0000, in: 0x01)!
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .inc(.bc)))
  }

  func test_inc_b() throws {
    let data = Data([0x04])
    let disassembly = Disassembler(data: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    let instruction = disassembly.instruction(at: 0x0000, in: 0x01)!
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .inc(.b)))
  }

  func test_dec_b() throws {
    let data = Data([0x05])
    let disassembly = Disassembler(data: data)
    disassembly.disassemble(range: 0..<UInt16(data.count), inBank: 0x01)

    let instruction = disassembly.instruction(at: 0x0000, in: 0x01)!
    XCTAssertEqual(instruction, LR35902.Instruction(spec: .dec(.b)))
  }
}

