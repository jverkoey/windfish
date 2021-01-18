import XCTest

import FoundationExtensions

class FixedWidthIntegerStringRepresentationTests: XCTestCase {

  func testHexStringZero() {
    XCTAssertEqual( UInt8(0).hexString, "00")
    XCTAssertEqual(UInt16(0).hexString, "0000")
    XCTAssertEqual(UInt32(0).hexString, "00000000")
    XCTAssertEqual(UInt64(0).hexString, "0000000000000000")
    XCTAssertEqual(   Int(0).hexString, "0000000000000000")
    XCTAssertEqual(  Int8(0).hexString, "00")
    XCTAssertEqual( Int16(0).hexString, "0000")
    XCTAssertEqual( Int32(0).hexString, "00000000")
    XCTAssertEqual( Int64(0).hexString, "0000000000000000")
    XCTAssertEqual(   Int(0).hexString, "0000000000000000")
  }

  func testHexStringOne() {
    XCTAssertEqual( UInt8(1).hexString, "01")
    XCTAssertEqual(UInt16(1).hexString, "0001")
    XCTAssertEqual(UInt32(1).hexString, "00000001")
    XCTAssertEqual(UInt64(1).hexString, "0000000000000001")
    XCTAssertEqual(   Int(1).hexString, "0000000000000001")
    XCTAssertEqual(  Int8(1).hexString, "01")
    XCTAssertEqual( Int16(1).hexString, "0001")
    XCTAssertEqual( Int32(1).hexString, "00000001")
    XCTAssertEqual( Int64(1).hexString, "0000000000000001")
    XCTAssertEqual(   Int(1).hexString, "0000000000000001")
  }

  func testHexStringMin() {
    XCTAssertEqual( UInt8.min.hexString, "00")
    XCTAssertEqual(UInt16.min.hexString, "0000")
    XCTAssertEqual(UInt32.min.hexString, "00000000")
    XCTAssertEqual(UInt64.min.hexString, "0000000000000000")
    XCTAssertEqual(   Int.min.hexString, "-8000000000000000")
    XCTAssertEqual(  Int8.min.hexString, "-80")
    XCTAssertEqual( Int16.min.hexString, "-8000")
    XCTAssertEqual( Int32.min.hexString, "-80000000")
    XCTAssertEqual( Int64.min.hexString, "-8000000000000000")
    XCTAssertEqual(   Int.min.hexString, "-8000000000000000")
  }

  func testHexStringMax() {
    XCTAssertEqual( UInt8.max.hexString, "FF")
    XCTAssertEqual(UInt16.max.hexString, "FFFF")
    XCTAssertEqual(UInt32.max.hexString, "FFFFFFFF")
    XCTAssertEqual(UInt64.max.hexString, "FFFFFFFFFFFFFFFF")
    XCTAssertEqual(   Int.max.hexString, "7FFFFFFFFFFFFFFF")
    XCTAssertEqual(  Int8.max.hexString, "7F")
    XCTAssertEqual( Int16.max.hexString, "7FFF")
    XCTAssertEqual( Int32.max.hexString, "7FFFFFFF")
    XCTAssertEqual( Int64.max.hexString, "7FFFFFFFFFFFFFFF")
    XCTAssertEqual(   Int.max.hexString, "7FFFFFFFFFFFFFFF")
  }
}
