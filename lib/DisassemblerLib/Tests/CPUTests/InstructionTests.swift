import XCTest
@testable import CPU

class InstructionTests: XCTestCase {
  func test_nop() {
    let instruction = SimpleCPU.Instruction(spec: .nop, immediate: nil)

    XCTAssertEqual(instruction.spec, .nop)
    XCTAssertNil(instruction.immediate)
  }

  func test_ld_imm8() {
    let instruction = SimpleCPU.Instruction(spec: .ld(.a, .imm8), immediate: .imm8(127))

    XCTAssertEqual(instruction.spec, .ld(.a, .imm8))
    XCTAssertEqual(instruction.immediate, .imm8(127))
  }

  func test_ld_imm16() {
    let instruction = SimpleCPU.Instruction(spec: .ld(.a, .imm16), immediate: .imm16(0xff11))

    XCTAssertEqual(instruction.spec, .ld(.a, .imm16))
    XCTAssertEqual(instruction.immediate, .imm16(0xff11))
  }

  func test_sub_cp_a() {
    let instruction = SimpleCPU.Instruction(spec: .sub(.cp(.a)), immediate: nil)

    XCTAssertEqual(instruction.spec, .sub(.cp(.a)))
    XCTAssertNil(instruction.immediate)
  }
}
