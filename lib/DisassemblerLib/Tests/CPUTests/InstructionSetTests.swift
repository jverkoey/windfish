import XCTest
@testable import CPU

class InstructionSetTests: XCTestCase {
  func testWidths() {
    XCTAssertEqual(SimpleCPU.InstructionSet.widths, [
      .nop: InstructionWidth(opcode: 1, operand: 0),
      .ld(.a, .imm8): InstructionWidth(opcode: 1, operand: 1),
      .ld(.a, .imm16): InstructionWidth(opcode: 1, operand: 2),
      .call(.nz, .imm16): InstructionWidth(opcode: 1, operand: 2),
      .call(nil, .imm16): InstructionWidth(opcode: 1, operand: 2),
      .sub(.cp(.imm8)): InstructionWidth(opcode: 2, operand: 1),
    ])
  }
}
