import XCTest

@testable import RGBDS

class InstructionOperandTokenTests: XCTestCase {

  func testStringInitialization() {
    XCTAssertEqual(InstructionOperandToken(string: "foo"), .specific("foo"))
    XCTAssertEqual(InstructionOperandToken(string: "123"), .numeric)
    XCTAssertEqual(InstructionOperandToken(string: "$123"), .numeric)
    XCTAssertEqual(InstructionOperandToken(string: "%123"), .numeric)
    XCTAssertEqual(InstructionOperandToken(string: "`123"), .numeric)
    XCTAssertEqual(InstructionOperandToken(string: "[$abcd]"), .address)
    XCTAssertEqual(InstructionOperandToken(string: "[$ffcd]"), .address)
    XCTAssertEqual(InstructionOperandToken(string: "[$ff]"), .address)
    XCTAssertEqual(InstructionOperandToken(string: "sp+$ff"), .stackPointerOffset)
    XCTAssertEqual(InstructionOperandToken(string: "SP+$ff"), .stackPointerOffset)
    XCTAssertEqual(InstructionOperandToken(string: "[$ff00+c]"), .specific("[$ff00+c]"))
    XCTAssertEqual(InstructionOperandToken(string: "[$FF00+c]"), .specific("[$FF00+c]"))
  }

  func testAsString() {
    XCTAssertEqual(InstructionOperandToken(string: "foo").asString(), "foo")
    XCTAssertEqual(InstructionOperandToken(string: "123").asString(), "#")
    XCTAssertEqual(InstructionOperandToken(string: "$123").asString(), "#")
    XCTAssertEqual(InstructionOperandToken(string: "%123").asString(), "#")
    XCTAssertEqual(InstructionOperandToken(string: "`123").asString(), "#")
    XCTAssertEqual(InstructionOperandToken(string: "[$abcd]").asString(), "[#]")
    XCTAssertEqual(InstructionOperandToken(string: "[$ffcd]").asString(), "[#]")
    XCTAssertEqual(InstructionOperandToken(string: "[$ff]").asString(), "[#]")
    XCTAssertEqual(InstructionOperandToken(string: "sp+$ff").asString(), "sp+#")
    XCTAssertEqual(InstructionOperandToken(string: "SP+$ff").asString(), "sp+#")
  }
}
