import XCTest

@testable import RGBDS

class ASCIITests: XCTestCase {

  func testEmpty() {
    XCTAssertEqual(Statement(withAscii: [], characterMap: [:]),
                   Statement(opcode: "db", operands: []))
  }

  func testString() {
    XCTAssertEqual(Statement(withAscii: [104, 101, 108, 108, 111], characterMap: [:]),
                   Statement(opcode: "db", operands: ["\"hello\""]))
  }

  func testCharacterMap() {
    XCTAssertEqual(Statement(withAscii: [104, 101, 108, 108, 111], characterMap: [104: "<h>"]),
                   Statement(opcode: "db", operands: ["\"<h>ello\""]))
    XCTAssertEqual(Statement(withAscii: [104, 101, 108, 108, 111], characterMap: [108: "<l>"]),
                   Statement(opcode: "db", operands: ["\"he<l><l>o\""]))
  }

  func testNonRepresentableCharacters() {
    XCTAssertEqual(Statement(withAscii: [0x0A, 104, 101, 108, 0x09, 108, 111, 0x03], characterMap: [:]),
                   Statement(opcode: "db", operands: ["$0A", "\"hel\"", "$09", "\"lo\"", "$03"]))
  }
}
