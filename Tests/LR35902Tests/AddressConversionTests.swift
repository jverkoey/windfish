import XCTest
@testable import LR35902

class AddressConversionTests: XCTestCase {

  func testZero() throws {
    let bank: LR35902.Bank = 0
    let address: LR35902.Address = 0
    let cartAddress = LR35902.cartAddress(for: address, in: bank)!
    let addressAndBank = LR35902.addressAndBank(from: cartAddress)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
  }

  func testMiddleOfBank0() throws {
    let bank: LR35902.Bank = 0
    let address: LR35902.Address = 0x2000
    let cartAddress = LR35902.cartAddress(for: address, in: bank)!
    let addressAndBank = LR35902.addressAndBank(from: cartAddress)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
  }

  func testEndOfBank0() throws {
    let bank: LR35902.Bank = 0
    let address: LR35902.Address = 0x3FFF
    let cartAddress = LR35902.cartAddress(for: address, in: bank)!
    let addressAndBank = LR35902.addressAndBank(from: cartAddress)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
  }
}
