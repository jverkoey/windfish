import XCTest

@testable import RGBDS

class ASCIITests: XCTestCase {

  func testEmpty() {
    XCTAssertEqual(statement(for: [], characterMap: [:]),
                   .init(opcode: "db", operands: []))
  }

  func testString() {
    XCTAssertEqual(statement(for: [104, 101, 108, 108, 111], characterMap: [:]),
                   .init(opcode: "db", operands: ["\"hello\""]))
  }

  func testCharacterMap() {
    XCTAssertEqual(statement(for: [104, 101, 108, 108, 111], characterMap: [104: "<h>"]),
                   .init(opcode: "db", operands: ["\"<h>ello\""]))
  }

  func testNonRepresentableCharacters() {
    XCTAssertEqual(statement(for: [0x0A, 104, 101, 108, 0x09, 108, 111, 0x03], characterMap: [:]),
                   .init(opcode: "db", operands: ["$0A", "\"hel\"", "$09", "\"lo\"", "$03"]))
  }
}
