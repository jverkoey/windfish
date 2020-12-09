import XCTest
@testable import CPU

class InstructionTests: XCTestCase {
  func testSpecAssignment() {
    let instruction = SimpleCPU.Instruction(spec: .nop)

    XCTAssertEqual(instruction.spec, .nop)
  }
}
