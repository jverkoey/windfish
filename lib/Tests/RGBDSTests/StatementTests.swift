import XCTest

@testable import RGBDS

class StatementTests: XCTestCase {

  // MARK: - Named operands

  func testWellFormedLineExtractsAllParts() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "ld a, b ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "b"])
    XCTAssertEqual(statement.formattedString, "ld   a, b")
    XCTAssertEqual(statement.tokenizedString, "ld a, b")
  }

  func testWellFormedLineWithExcessiveSpaceExtractsAllParts() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "     ld       a   ,    [ $ff00 ]      ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "[$ff00]"])
    XCTAssertEqual(statement.formattedString, "ld   a, [$ff00]")
    XCTAssertEqual(statement.tokenizedString, "ld a, [#]")
  }

  func testWellFormedLineWithExcessiveSpaceAndStringExtractsAllParts() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "     ld       a   ,    \"some string\"      ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "\"some string\""])
    XCTAssertEqual(statement.formattedString, "ld   a, \"some string\"")
    XCTAssertEqual(statement.tokenizedString, "ld a, \"some string\"")
  }

  func testOnlyOpcode() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "nop"))

    XCTAssertEqual(statement.opcode, "nop")
    XCTAssertEqual(statement.operands, [])
    XCTAssertEqual(statement.formattedString, "nop")
    XCTAssertEqual(statement.tokenizedString, "nop")
  }

  func testOnlyCommentIsNotAStatement() throws {
    XCTAssertNil(Statement(fromLine: "; some comment"))
  }

  func testMultipleArgumentsAreExtracted() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "ld a, b, c, d ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "b", "c", "d"])
    XCTAssertEqual(statement.formattedString, "ld   a, b, c, d")
    XCTAssertEqual(statement.tokenizedString, "ld a, b, c, d")
  }

  func testStringArgumentsAreExtracted() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "ld a, \"foo\" ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "\"foo\""])
    XCTAssertEqual(statement.formattedString, "ld   a, \"foo\"")
    XCTAssertEqual(statement.tokenizedString, "ld a, \"foo\"")
  }

  // MARK: - Numeric operands

  func testWellFormedLineWithDecimalNumericOperandsExtractsAllParts() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "ld a, 123 ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "123"])
    XCTAssertEqual(statement.formattedString, "ld   a, 123")
    XCTAssertEqual(statement.tokenizedString, "ld a, #")
  }

  func testWellFormedLineWithHexOperandsExtractsAllParts() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "ld a, $ff00 ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "$ff00"])
    XCTAssertEqual(statement.formattedString, "ld   a, $ff00")
    XCTAssertEqual(statement.tokenizedString, "ld a, #")
  }

  func testWellFormedLineWithBinaryOperandsExtractsAllParts() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "ld a, %00001000 ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "%00001000"])
    XCTAssertEqual(statement.formattedString, "ld   a, %00001000")
    XCTAssertEqual(statement.tokenizedString, "ld a, #")
  }

  func testWellFormedLineWithOctalOperandsExtractsAllParts() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "ld a, &00001000 ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "&00001000"])
    XCTAssertEqual(statement.formattedString, "ld   a, &00001000")
    XCTAssertEqual(statement.tokenizedString, "ld a, #")
  }

  func testWellFormedLineWithGameboyGraphicsOperandsExtractsAllParts() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "ld a, `00001000 ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "`00001000"])
    XCTAssertEqual(statement.formattedString, "ld   a, `00001000")
    XCTAssertEqual(statement.tokenizedString, "ld a, #")
  }

  func testWellFormedLineWithPlaceholderOperandsExtractsAllParts() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "ld a, #1 ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "#1"])
    XCTAssertEqual(statement.formattedString, "ld   a, #1")
    XCTAssertEqual(statement.tokenizedString, "ld a, #")
  }

  func testWellFormedLineWithFloatingPointOperandsExtractsAllParts() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "ld a, 123.456 ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "123.456"])
    XCTAssertEqual(statement.formattedString, "ld   a, 123.456")
    XCTAssertEqual(statement.tokenizedString, "ld a, #")
  }

  func testTraditionalHexRepresentationNotSupported() throws {
    let statement = try XCTUnwrap(Statement(fromLine: "ld a, 0xff00 ; some comment"))

    XCTAssertEqual(statement.opcode, "ld")
    XCTAssertEqual(statement.operands, ["a", "0xff00"])
    XCTAssertEqual(statement.formattedString, "ld   a, 0xff00")
    XCTAssertEqual(statement.tokenizedString, "ld a, 0xff00")
  }

  // MARK: - Data statements

  func testDataStatement() throws {
    let statement = try XCTUnwrap(Statement(representingBytes: Data([0x00, 0xfa])))

    XCTAssertEqual(statement.opcode, "db")
    XCTAssertEqual(statement.operands, ["$00", "$FA"])
    XCTAssertEqual(statement.formattedString, "db   $00, $FA")
    XCTAssertEqual(statement.tokenizedString, "db #, #")
  }
}
