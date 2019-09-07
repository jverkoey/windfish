import XCTest
@testable import CPU

struct TestInstruction: Instruction {
  var spec: TestInstruction.Spec

  func operandData() -> Data? {
    return nil
  }

  indirect enum Spec: InstructionSpec, Hashable {
    case nop
    case ld(Operand)
    case ld(Operand, Operand)
    case sub(Spec)

    typealias WidthType = UInt16

    var category: InstructionCategory? {
      return nil
    }

    func asData() -> Data? {
      return nil
    }
  }

  enum Operand: Hashable, InstructionOperandAssemblyRepresentable {
    case imm8
    case imm16
    case a
    case arg(Int)

    var representation: InstructionOperandAssemblyRepresentation {
      switch self {
      case .imm8, .imm16:
        return .numeric
      default:
        return .specific("\(self)")
      }
    }
  }
}

class VisitorTests: XCTestCase {

  func testInstructionWithNoOperandsIsVisitedWithNil() throws {
    let instruction = TestInstruction(spec: .nop)

    var visitCount = 0
    instruction.spec.visit { (operand, index) in
      visitCount += 1
      XCTAssertNil(operand)
      XCTAssertNil(index)
    }
    XCTAssertEqual(visitCount, 1)
  }

  func testInstructionWithOneOperandIsVisitedOnce() throws {
    let instruction = TestInstruction(spec: .ld(.imm8))

    var visitCount = 0
    var visitedOperands: [TestInstruction.Operand] = []
    var visitedIndices: [Int] = []
    instruction.spec.visit { (operand, index) in
      if let operand = operand as? TestInstruction.Operand,
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
    let instruction = TestInstruction(spec: .ld(.a, .imm8))

    var visitCount = 0
    var visitedOperands: [TestInstruction.Operand] = []
    var visitedIndices: [Int] = []
    instruction.spec.visit { (operand, index) in
      if let operand = operand as? TestInstruction.Operand,
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
    let instruction = TestInstruction(spec: .sub(.ld(.a, .imm8)))

    var visitCount = 0
    var visitedOperands: [TestInstruction.Operand] = []
    var visitedIndices: [Int] = []
    instruction.spec.visit { (operand, index) in
      if let operand = operand as? TestInstruction.Operand,
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
    XCTAssertEqual(TestInstruction.Spec.nop.representation, "nop")
    XCTAssertEqual(TestInstruction.Spec.ld(.a, .imm8).representation, "ld a, #")
    XCTAssertEqual(TestInstruction.Spec.sub(.ld(.imm8, .a)).representation, "ld #, a")
    XCTAssertEqual(TestInstruction.Spec.sub(.ld(.a)).representation, "ld a")
    XCTAssertEqual(TestInstruction.Spec.ld(.arg(1)).representation, "ld arg(1)")
  }
}
