import XCTest
@testable import CPU

class InstructionSpecTests: XCTestCase {
  func test_nop() {
    let spec = SimpleCPU.Instruction.Spec.nop

    XCTAssertEqual(spec.opcodeWidth, 1)
    XCTAssertEqual(spec.operandWidth, 0)
  }

  func test_ld_a_imm8() {
    let spec = SimpleCPU.Instruction.Spec.ld(.a, .imm8)

    XCTAssertEqual(spec.opcodeWidth, 1)
    XCTAssertEqual(spec.operandWidth, 1)
  }

  func test_ld_a_imm16() {
    let spec = SimpleCPU.Instruction.Spec.ld(.a, .imm16)

    XCTAssertEqual(spec.opcodeWidth, 1)
    XCTAssertEqual(spec.operandWidth, 2)
  }

  func test_sub_cp_a() {
    let spec = SimpleCPU.Instruction.Spec.sub(.cp(.a))

    XCTAssertEqual(spec.opcodeWidth, 2)
    XCTAssertEqual(spec.operandWidth, 0)
  }
}
