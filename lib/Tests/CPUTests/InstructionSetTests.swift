import XCTest
@testable import CPU

class InstructionSetTests: XCTestCase {
  func testWidths() {
    XCTAssertEqual(SimpleCPU.InstructionSet.widths, [
      .nop: InstructionWidth(opcode: 1, immediate: 0),
      .ld(.a, .imm8): InstructionWidth(opcode: 1, immediate: 1),
      .ld(.a, .imm16): InstructionWidth(opcode: 1, immediate: 2),
      .call(.nz, .imm16): InstructionWidth(opcode: 1, immediate: 2),
      .call(nil, .imm16): InstructionWidth(opcode: 1, immediate: 2),
      .prefix(.sub): InstructionWidth(opcode: 1, immediate: 0),
      .sub(.cp(.imm8)): InstructionWidth(opcode: 2, immediate: 1),
    ])
  }

  func testOpcodeBytes() {
    let opcodes: [SimpleCPU.Instruction.Spec : [UInt8]] = [
      .nop: [0],
      .ld(.a, .imm8): [1],
      .ld(.a, .imm16): [2],
      .call(.nz, .imm16): [3],
      .call(nil, .imm16): [4],
      .sub(.cp(.imm8)): [5, 0],
    ]
    for (key, value) in SimpleCPU.InstructionSet.opcodeBytes {
      XCTAssertEqual(value, opcodes[key], "\(key) mismatched")
    }
    XCTAssertEqual(SimpleCPU.InstructionSet.opcodeBytes.count, opcodes.count)
  }

  func testOpcodeData() {
    let opcodeData: [SimpleCPU.Instruction.Spec : [UInt8]?] = [
      .nop: [0],
      .ld(.a, .imm8): [1],
      .ld(.a, .imm16): [2],
      .call(.nz, .imm16): [3],
      .call(nil, .imm16): [4],
      .prefix(.sub): nil,
      .sub(.cp(.imm8)): [5, 0],
    ]
    for spec in SimpleCPU.InstructionSet.allSpecs() {
      let value = SimpleCPU.InstructionSet.opcodeBytes[spec]
      XCTAssertEqual(value, opcodeData[spec], "\(spec) mismatched")
    }
    XCTAssertEqual(SimpleCPU.InstructionSet.allSpecs().count, opcodeData.count)
  }

  func testOpcodeStrings() {
    let opcodeStrings: [SimpleCPU.Instruction.Spec : String] = [
      .nop: "nop",
      .ld(.a, .imm8): "ld",
      .ld(.a, .imm16): "ld",
      .call(.nz, .imm16): "call",
      .call(nil, .imm16): "call",
      .sub(.cp(.imm8)): "cp",
    ]
    for (key, value) in SimpleCPU.InstructionSet.opcodeStrings {
      XCTAssertEqual(value, opcodeStrings[key], "\(key) mismatched")
    }
    XCTAssertEqual(SimpleCPU.InstructionSet.opcodeStrings.count, opcodeStrings.count)
  }
}
