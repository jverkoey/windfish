import XCTest
@testable import LR35902

class AddressConversionTests: XCTestCase {

  func testZero() throws {
    let bank: LR35902.Bank = 0
    let address: LR35902.Address = 0
    let cartridgeLocation = Gameboy.Cartridge.location(for: address, in: bank)!
    let addressAndBank = Gameboy.Cartridge.addressAndBank(from: cartridgeLocation)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
  }

  func testMiddleOfBank0() throws {
    let bank: LR35902.Bank = 0
    let address: LR35902.Address = 0x2000
    let cartridgeLocation = Gameboy.Cartridge.location(for: address, in: bank)!
    let addressAndBank = Gameboy.Cartridge.addressAndBank(from: cartridgeLocation)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
  }

  func testEndOfBank0() throws {
    let bank: LR35902.Bank = 0
    let address: LR35902.Address = 0x3FFF
    let cartridgeLocation = Gameboy.Cartridge.location(for: address, in: bank)!
    let addressAndBank = Gameboy.Cartridge.addressAndBank(from: cartridgeLocation)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
  }

  func testUnselectedBankGivesNilCartAddressAbove0x3FFF() throws {
    XCTAssertNil(Gameboy.Cartridge.location(for: 0x4000, in: 0))
    XCTAssertNil(Gameboy.Cartridge.location(for: 0x6000, in: 0))
    XCTAssertNil(Gameboy.Cartridge.location(for: 0x9000, in: 0))
  }

  func testBeginningOfBank1() throws {
    let bank: LR35902.Bank = 1
    let address: LR35902.Address = 0x4000
    let cartridgeLocation = Gameboy.Cartridge.location(for: address, in: bank)!
    let addressAndBank = Gameboy.Cartridge.addressAndBank(from: cartridgeLocation)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
    XCTAssertEqual(cartridgeLocation, 0x4000)
  }

  func testBeginningOfBank2() throws {
    let bank: LR35902.Bank = 2
    let address: LR35902.Address = 0x4000
    let cartridgeLocation = Gameboy.Cartridge.location(for: address, in: bank)!
    let addressAndBank = Gameboy.Cartridge.addressAndBank(from: cartridgeLocation)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, bank)
    XCTAssertEqual(cartridgeLocation, 0x8000)
  }

  func testBank0WithBank1Selected() throws {
    let bank: LR35902.Bank = 1
    let address: LR35902.Address = 0x2000
    let cartridgeLocation = Gameboy.Cartridge.location(for: address, in: bank)!
    let addressAndBank = Gameboy.Cartridge.addressAndBank(from: cartridgeLocation)
    XCTAssertEqual(addressAndBank.address, address)
    XCTAssertEqual(addressAndBank.bank, 0)
    XCTAssertEqual(cartridgeLocation, 0x2000)
  }

  func testAddressAndBankEndOfBank0() throws {
    let addressAndBank = Gameboy.Cartridge.addressAndBank(from: 0x3FFF)
    XCTAssertEqual(addressAndBank.address, 0x3FFF)
    XCTAssertEqual(addressAndBank.bank, 0)
  }

  func testAddressAndBankBeginningOfBank1() throws {
    let addressAndBank = Gameboy.Cartridge.addressAndBank(from: 0x4000)
    XCTAssertEqual(addressAndBank.address, 0x4000)
    XCTAssertEqual(addressAndBank.bank, 1)
  }

  func testAddressAndBankBeginningOfBank2() throws {
    let addressAndBank = Gameboy.Cartridge.addressAndBank(from: 0x8000)
    XCTAssertEqual(addressAndBank.address, 0x4000)
    XCTAssertEqual(addressAndBank.bank, 2)
  }
}
