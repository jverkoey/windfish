import XCTest

@testable import RGBDS

class StatementTests: XCTestCase {

  func testWellFormedLineExtractsAllParts() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "ld a, b ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "b"])
  }

  func testWellFormedLineWithExcessiveSpaceExtractsAllParts() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "     ld       a   ,    b      ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "b"])
  }

  func testOnlyOpcode() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "nop"))

    XCTAssertEqual(statement.opcode, "nop")
    XCTAssertEqual(statement.operands, [])
  }

  func testOnlyCommentIsNotAStatement() throws {
    XCTAssertNil(Statement(fromLine: "; some comment"))
  }
}
