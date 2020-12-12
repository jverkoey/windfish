import XCTest

@testable import RGBDS

class ASCIITests: XCTestCase {

  func testEmpty() {
    XCTAssertEqual(asciiString(for: [], characterMap: [:]), "")
  }

  func testString() {
    XCTAssertEqual(asciiString(for: [104, 101, 108, 108, 111], characterMap: [:]), "hello")
  }

  func testCharacterMap() {
    XCTAssertEqual(asciiString(for: [104, 101, 108, 108, 111], characterMap: [104: "<h>"]), "<h>ello")
  }
}
