import XCTest
@testable import CPU

class VisitorTests: XCTestCase {

  func testInstructionWithNoOperandsIsVisitedWithNil() throws {
    let instruction = SimpleCPU.TestInstruction(spec: .nop)

    var visitCount = 0
    instruction.spec.visit { (operand, index) in
      visitCount += 1
      XCTAssertNil(operand)
      XCTAssertNil(index)
    }
    XCTAssertEqual(visitCount, 1)
  }

  func testInstructionWithOneOperandIsVisitedOnce() throws {
    let instruction = SimpleCPU.TestInstruction(spec: .ld(.imm8))

    var visitCount = 0
    var visitedOperands: [SimpleCPU.TestInstruction.Operand] = []
    var visitedIndices: [Int] = []
    instruction.spec.visit { (operand, index) in
      if let operand = operand as? SimpleCPU.TestInstruction.Operand,
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
    let instruction = SimpleCPU.TestInstruction(spec: .ld(.a, .imm8))

    var visitCount = 0
    var visitedOperands: [SimpleCPU.TestInstruction.Operand] = []
    var visitedIndices: [Int] = []
    instruction.spec.visit { (operand, index) in
      if let operand = operand as? SimpleCPU.TestInstruction.Operand,
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
    let instruction = SimpleCPU.TestInstruction(spec: .sub(.ld(.a, .imm8)))

    var visitCount = 0
    var visitedOperands: [SimpleCPU.TestInstruction.Operand] = []
    var visitedIndices: [Int] = []
    instruction.spec.visit { (operand, index) in
      if let operand = operand as? SimpleCPU.TestInstruction.Operand,
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

  func testRepresentation() throws {
    XCTAssertEqual(SimpleCPU.TestInstruction.Spec.nop.representation, "nop")
    XCTAssertEqual(SimpleCPU.TestInstruction.Spec.ld(.a, .imm8).representation, "ld a, #")
    XCTAssertEqual(SimpleCPU.TestInstruction.Spec.sub(.ld(.imm8, .a)).representation, "ld #, a")
    XCTAssertEqual(SimpleCPU.TestInstruction.Spec.sub(.ld(.a)).representation, "ld a")
    XCTAssertEqual(SimpleCPU.TestInstruction.Spec.ld(.arg(1)).representation, "ld arg(1)")
  }
}
