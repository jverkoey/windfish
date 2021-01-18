import XCTest
@testable import Windfish

class AddressConversionTests: XCTestCase {

  func testZero() throws {
    let bank: Cartridge.Bank = 0x01
    let address: LR35902.Address = 0
    let cartridgeLocation = Cartridge.location(for: address, in: bank)!
    let addressAndBank = Cartridge.addressAndBank(from: cartridgeLocation)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
  }

  func testMiddleOfBank0() throws {
    let bank: Cartridge.Bank = 0x01
    let address: LR35902.Address = 0x2000
    let cartridgeLocation = Cartridge.location(for: address, in: bank)!
    let addressAndBank = Cartridge.addressAndBank(from: cartridgeLocation)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
  }

  func testEndOfBank0() throws {
    let bank: Cartridge.Bank = 0x01
    let address: LR35902.Address = 0x3FFF
    let cartridgeLocation = Cartridge.location(for: address, in: bank)!
    let addressAndBank = Cartridge.addressAndBank(from: cartridgeLocation)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
  }

  func testUnselectedBankGivesNilCartAddressAbove0x8FFF() throws {
    XCTAssertEqual(Cartridge.location(for: 0x4000, in: 0x01), 0x4000)
    XCTAssertEqual(Cartridge.location(for: 0x6000, in: 0x01), 0x6000)
    XCTAssertNil(Cartridge.location(for: 0x9000, in: 0x01))
  }

  func testBeginningOfBank1() throws {
    let bank: Cartridge.Bank = 0x01
    let address: LR35902.Address = 0x4000
    let cartridgeLocation = Cartridge.location(for: address, in: bank)!
    let addressAndBank = Cartridge.addressAndBank(from: cartridgeLocation)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
    XCTAssertEqual(cartridgeLocation, 0x4000)
  }

  func testBeginningOfBank2() throws {
    let bank: Cartridge.Bank = 2
    let address: LR35902.Address = 0x4000
    let cartridgeLocation = Cartridge.location(for: address, in: bank)!
    let addressAndBank = Cartridge.addressAndBank(from: cartridgeLocation)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
    XCTAssertEqual(cartridgeLocation, 0x8000)
  }

  func testBank0WithBank1Selected() throws {
    let bank: Cartridge.Bank = 0x01
    let address: LR35902.Address = 0x2000
    let cartridgeLocation = Cartridge.location(for: address, in: bank)!
    let addressAndBank = Cartridge.addressAndBank(from: cartridgeLocation)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, 0x01)
    XCTAssertEqual(cartridgeLocation, 0x2000)
  }

  func testAddressAndBankEndOfBank0() throws {
    let addressAndBank = Cartridge.addressAndBank(from: 0x3FFF)
    XCTAssertEqual(addressAndBank.address, 0x3FFF)
    XCTAssertEqual(addressAndBank.bank, 0x01)
  }

  func testAddressAndBankBeginningOfBank1() throws {
    let addressAndBank = Cartridge.addressAndBank(from: 0x4000)
    XCTAssertEqual(addressAndBank.address, 0x4000)
    XCTAssertEqual(addressAndBank.bank, 1)
  }

  func testAddressAndBankBeginningOfBank2() throws {
    let addressAndBank = Cartridge.addressAndBank(from: 0x8000)
    XCTAssertEqual(addressAndBank.address, 0x4000)
    XCTAssertEqual(addressAndBank.bank, 2)
  }
}
