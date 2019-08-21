import XCTest
@testable import LR35902

class AddressConversionTests: XCTestCase {

  func testZero() throws {
    let bank: LR35902.Bank = 0
    let address: LR35902.Address = 0
    let cartAddress = try XCTUnwrap(LR35902.cartAddress(for: address, in: bank))
    let addressAndBank = LR35902.addressAndBank(from: cartAddress)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
  }

  func testMiddleOfBank0() throws {
    let bank: LR35902.Bank = 0
    let address: LR35902.Address = 0x2000
    let cartAddress = try XCTUnwrap(LR35902.cartAddress(for: address, in: bank))
    let addressAndBank = LR35902.addressAndBank(from: cartAddress)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
  }

  func testEndOfBank0() throws {
    let bank: LR35902.Bank = 0
    let address: LR35902.Address = 0x3FFF
    let cartAddress = try XCTUnwrap(LR35902.cartAddress(for: address, in: bank))
    let addressAndBank = LR35902.addressAndBank(from: cartAddress)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
  }

  func testUnselectedBankGivesNilCartAddressAbove0x3FFF() throws {
    XCTAssertNil(LR35902.cartAddress(for: 0x4000, in: 0))
    XCTAssertNil(LR35902.cartAddress(for: 0x6000, in: 0))
    XCTAssertNil(LR35902.cartAddress(for: 0x9000, in: 0))
  }

  func testBeginningOfBank1() throws {
    let bank: LR35902.Bank = 1
    let address: LR35902.Address = 0x4000
    let cartAddress = try XCTUnwrap(LR35902.cartAddress(for: address, in: bank))
    let addressAndBank = LR35902.addressAndBank(from: cartAddress)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
    XCTAssertEqual(cartAddress, 0x4000)
  }

  func testBeginningOfBank2() throws {
    let bank: LR35902.Bank = 2
    let address: LR35902.Address = 0x4000
    let cartAddress = try XCTUnwrap(LR35902.cartAddress(for: address, in: bank))
    let addressAndBank = LR35902.addressAndBank(from: cartAddress)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
    XCTAssertEqual(cartAddress, 0x8000)
  }

  func testBank0WithBank1Selected() throws {
    let bank: LR35902.Bank = 1
    let address: LR35902.Address = 0x2000
    let cartAddress = try XCTUnwrap(LR35902.cartAddress(for: address, in: bank))
    let addressAndBank = LR35902.addressAndBank(from: cartAddress)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, 0)
    XCTAssertEqual(cartAddress, 0x2000)
  }
}
