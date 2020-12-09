import XCTest
@testable import CPU

class VisitorTests: XCTestCase {

  func testInstructionWithNoOperandsIsVisitedWithNil() throws {
    let instruction = SimpleCPU.Instruction(spec: .nop)

    var visitCount = 0
    instruction.spec.visit { (operand, index) in
      visitCount += 1
      XCTAssertNil(operand)
      XCTAssertNil(index)
    }
    XCTAssertEqual(visitCount, 1)
  }

  func testInstructionWithOneOperandIsVisitedOnce() throws {
    let instruction = SimpleCPU.Instruction(spec: .ld(.imm8))

    var visitCount = 0
    var visitedOperands: [SimpleCPU.Instruction.Operand] = []
    var visitedIndices: [Int] = []
    instruction.spec.visit { (operand, index) in
      if let operand = operand as? SimpleCPU.Instruction.Operand,
        let index = index {
        visitedOperands.append(operand)
        visitedIndices.append(index)
      }
      visitCount += 1
    }
    XCTAssertEqual(visitedOperands, [.imm8])
    XCTAssertEqual(visitedIndices, [0])
    XCTAssertEqual(visitCount, 1)
  }

  func testInstructionWithTwoOperandsIsVisitedTwice() throws {
    let instruction = SimpleCPU.Instruction(spec: .ld(.a, .imm8))

    var visitCount = 0
    var visitedOperands: [SimpleCPU.Instruction.Operand] = []
    var visitedIndices: [Int] = []
    instruction.spec.visit { (operand, index) in
      if let operand = operand as? SimpleCPU.Instruction.Operand,
        let index = index {
        visitedOperands.append(operand)
        visitedIndices.append(index)
      }
      visitCount += 1
    }
    XCTAssertEqual(visitedOperands, [.a, .imm8])
    XCTAssertEqual(visitedIndices, [0, 1])
    XCTAssertEqual(visitCount, 2)
  }

  func testNestedInstructionWithTwoOperandsIsVisitedTwice() throws {
    let instruction = SimpleCPU.Instruction(spec: .sub(.ld(.a, .imm8)))

    var visitCount = 0
    var visitedOperands: [SimpleCPU.Instruction.Operand] = []
    var visitedIndices: [Int] = []
    instruction.spec.visit { (operand, index) in
      if let operand = operand as? SimpleCPU.Instruction.Operand,
        let index = index {
        visitedOperands.append(operand)
        visitedIndices.append(index)
      }
      visitCount += 1
    }
    XCTAssertEqual(visitedOperands, [.a, .imm8])
    XCTAssertEqual(visitedIndices, [0, 1])
    XCTAssertEqual(visitCount, 2)
  }
}
