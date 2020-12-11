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
      .prefix(.sub): InstructionWidth(opcode: 1, operand: 0),
      .sub(.cp(.imm8)): InstructionWidth(opcode: 2, operand: 1),
    ])
  }

  func testOpcodes() {
    let opcodes: [SimpleCPU.Instruction.Spec : [UInt8]] = [
      .nop: [0],
      .ld(.a, .imm8): [1],
      .ld(.a, .imm16): [2],
      .call(.nz, .imm16): [3],
      .call(nil, .imm16): [4],
      .prefix(.sub): [5],
      .sub(.cp(.imm8)): [5, 0],
    ]
    for (key, value) in SimpleCPU.InstructionSet.instructionOpcodes {
      XCTAssertEqual(value, opcodes[key], "\(key) mismatched")
    }
  }
}
