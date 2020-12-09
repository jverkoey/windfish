import XCTest
@testable import CPU

class InstructionTests: XCTestCase {
  func testSomething() {
    let instruction = SimpleCPU.Instruction(spec: .nop)
  }
}
