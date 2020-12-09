import XCTest
@testable import CPU

class InstructionSpecTests: XCTestCase {
  func testSpecWithNoOperand() {
    let spec = SimpleCPU.Instruction.Spec.nop

    XCTAssertEqual(spec.opcodeWidth, 1)
    XCTAssertEqual(spec.operandWidth, 0)
  }
}
