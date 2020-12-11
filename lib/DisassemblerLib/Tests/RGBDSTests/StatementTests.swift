import XCTest

@testable import RGBDS

class StatementTests: XCTestCase {

  func testWellFormedLineExtractsAllParts() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "ld a, b ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "b"])
  }

  func testOnlyComment() throws {
    XCTAssertNil(Statement(fromLine: "; some comment"))
  }
}
