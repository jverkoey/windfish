import XCTest

import FoundationExtensions

class StringProtocolTrimmedTests: XCTestCase {

  func testVariousStrings() {
    XCTAssertEqual("".trimmed(), "")
    XCTAssertEqual("somestring".trimmed(), "somestring")
    XCTAssertEqual("  somestring".trimmed(), "somestring")
    XCTAssertEqual("somestring  ".trimmed(), "somestring")
    XCTAssertEqual("  somestring  ".trimmed(), "somestring")
    XCTAssertEqual("  somestring  somestring  ".trimmed(), "somestring  somestring")
    XCTAssertEqual("  somestring \n somestring  ".trimmed(), "somestring \n somestring")
    XCTAssertEqual("  somestring  \n  ".trimmed(), "somestring")
  }
}
