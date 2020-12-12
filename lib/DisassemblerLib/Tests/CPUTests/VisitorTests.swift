import XCTest
@testable import CPU

private final class VisitorMonitor {
  struct Visited: Equatable {
    let numericValue: SimpleCPU.Instruction.Spec.Numeric?
    let conditionValue: SimpleCPU.Instruction.Spec.Condition?
    let operandIndex: Int?
  }
  var visited: [Visited] = []
  func visit(_ operand: (value: Any, index: Int)?) {
    visited.append(Visited(numericValue: operand?.value as? SimpleCPU.Instruction.Spec.Numeric,
                           conditionValue: operand?.value as? SimpleCPU.Instruction.Spec.Condition,
                           operandIndex: operand?.index))
  }
}

class VisitorTests: XCTestCase {

  func testNoOperandsIsVisitedWithNil() throws {
    let instruction = SimpleCPU.Instruction(spec: .nop, immediate: nil)

    let monitor = VisitorMonitor()
    try instruction.spec.visit(visitor: monitor.visit)
    XCTAssertEqual(monitor.visited, [
      .init(numericValue: nil, conditionValue: nil, operandIndex: nil)
    ])
  }

  func testOneOperandIsVisitedOnce() throws {
    let instruction = SimpleCPU.Instruction(spec: .cp(.a), immediate: nil)

    let monitor = VisitorMonitor()
    try instruction.spec.visit(visitor: monitor.visit)

    XCTAssertEqual(monitor.visited, [
      .init(numericValue: SimpleCPU.Instruction.Spec.Numeric.a, conditionValue: nil, operandIndex: 0)
    ])
  }

  func testTwoOperandsIsVisitedTwice() throws {
    let instruction = SimpleCPU.Instruction(spec: .ld(.a, .imm8), immediate: .imm8(128))

    let monitor = VisitorMonitor()
    try instruction.spec.visit(visitor: monitor.visit)

    XCTAssertEqual(monitor.visited, [
      .init(numericValue: SimpleCPU.Instruction.Spec.Numeric.a, conditionValue: nil, operandIndex: 0),
      .init(numericValue: SimpleCPU.Instruction.Spec.Numeric.imm8, conditionValue: nil, operandIndex: 1)
    ])
  }

  func testNestedTwoOperandsIsVisitedTwice() throws {
    let instruction = SimpleCPU.Instruction(spec: .sub(.ld(.a, .imm8)), immediate: .imm8(128))

    let monitor = VisitorMonitor()
    try instruction.spec.visit(visitor: monitor.visit)

    XCTAssertEqual(monitor.visited, [
      .init(numericValue: SimpleCPU.Instruction.Spec.Numeric.a, conditionValue: nil, operandIndex: 0),
      .init(numericValue: SimpleCPU.Instruction.Spec.Numeric.imm8, conditionValue: nil, operandIndex: 1)
    ])
  }

  func testNilOperandIsSkipped() throws {
    let instruction = SimpleCPU.Instruction(spec: .call(nil, .imm8), immediate: .imm8(128))

    let monitor = VisitorMonitor()
    try instruction.spec.visit(visitor: monitor.visit)

    XCTAssertEqual(monitor.visited, [
      .init(numericValue: SimpleCPU.Instruction.Spec.Numeric.imm8, conditionValue: nil, operandIndex: 0)
    ])
  }

  func testNonNilOptionalOperandIsVisited() throws {
    let instruction = SimpleCPU.Instruction(spec: .call(.nz, .imm8), immediate: .imm8(128))

    let monitor = VisitorMonitor()
    try instruction.spec.visit(visitor: monitor.visit)

    XCTAssertEqual(monitor.visited, [
      .init(numericValue: nil, conditionValue: SimpleCPU.Instruction.Spec.Condition.nz, operandIndex: 0),
      .init(numericValue: SimpleCPU.Instruction.Spec.Numeric.imm8, conditionValue: nil, operandIndex: 1)
    ])
  }
}
