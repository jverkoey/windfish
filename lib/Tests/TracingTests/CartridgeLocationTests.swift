import XCTest

import LR35902
import Tracing

class CartridgeLocationTests: XCTestCase {

  // MARK: - Initialization

  func testZeroBank0() throws {
    let location = Cartridge.Location(address: 0, bank: 0)
    XCTAssertEqual(location.address, 0)
    XCTAssertEqual(location.bank, 1)
    XCTAssertEqual(location.index, 0)
  }

  func testOneBank0() throws {
    let location = Cartridge.Location(address: 1, bank: 0)
    XCTAssertEqual(location.address, 1)
    XCTAssertEqual(location.bank, 1)
    XCTAssertEqual(location.index, 1)
  }

  func testZeroBank1() throws {
    let location = Cartridge.Location(address: 0, bank: 1)
    XCTAssertEqual(location.address, 0)
    XCTAssertEqual(location.bank, 1)
    XCTAssertEqual(location.index, 0)
  }

  func testZeroBank2() throws {
    let location = Cartridge.Location(address: 0, bank: 2)
    XCTAssertEqual(location.address, 0)
    XCTAssertEqual(location.bank, 1)
    XCTAssertEqual(location.index, 0)
  }

  func testBeginningOfBank2() throws {
    let location = Cartridge.Location(address: 0x4000, bank: 2)
    XCTAssertEqual(location.address, 0x4000)
    XCTAssertEqual(location.bank, 2)
    XCTAssertEqual(location.index, 0x8000)
  }

  func testEdgeOfBankAddress() throws {
    let location = Cartridge.Location(address: 0x8000, bank: 1)
    XCTAssertEqual(location.address, 0x8000)
    XCTAssertEqual(location.bank, 1)
    XCTAssertEqual(location.index, 0x8000)
  }

  // MARK: - Operators

  func testAdditionInt() throws {
    let location = Cartridge.Location(address: 0x4000, bank: 1) + 0x100
    XCTAssertEqual(location.address, 0x4100)
    XCTAssertEqual(location.bank, 1)
    XCTAssertEqual(location.index, 0x4100)
  }

  func testAdditionIntBeyondBank() throws {
    let location = Cartridge.Location(address: 0x8000, bank: 1) + 0x100
    XCTAssertEqual(location.address, 0x8100)
    XCTAssertEqual(location.bank, 1)
    XCTAssertEqual(location.index, 0x8100)
  }

  func testAdditionAddress() throws {
    let location = Cartridge.Location(address: 0x4000, bank: 1) + LR35902.Address(0x100)
    XCTAssertEqual(location.address, 0x4100)
    XCTAssertEqual(location.bank, 1)
    XCTAssertEqual(location.index, 0x4100)
  }

  func testAdditionAddressBeyondBank() throws {
    let location = Cartridge.Location(address: 0x8000, bank: 1) + LR35902.Address(0x100)
    XCTAssertEqual(location.address, 0x8100)
    XCTAssertEqual(location.bank, 1)
    XCTAssertEqual(location.index, 0x8100)
  }

  // MARK: - Hashing

  func testHashing() throws {
    let location1 = Cartridge.Location(address: 0x4000, bank: 1)
    let location2 = Cartridge.Location(address: 0x4000, bank: 2)
    let locations = Set<Cartridge.Location>([location1, location2])
    XCTAssertEqual(locations.count, 2)
  }

  // MARK: - Equality

  func testEquality() throws {
    XCTAssertEqual(Cartridge.Location(address: 0x4000, bank: 1), Cartridge.Location(address: 0x4000, bank: 1))
    XCTAssertEqual(Cartridge.Location(address: 0x100, bank: 0), Cartridge.Location(address: 0x100, bank: 1))
    XCTAssertNotEqual(Cartridge.Location(address: 0x4000, bank: 1), Cartridge.Location(address: 0x4000, bank: 2))
    XCTAssertNotEqual(Cartridge.Location(address: 0x4001, bank: 1), Cartridge.Location(address: 0x4000, bank: 1))

    // Addresses beyond a bank's edge wrap into the next bank when comparing.
    XCTAssertEqual(Cartridge.Location(address: 0x8000, bank: 1), Cartridge.Location(address: 0x4000, bank: 2))
  }

  // MARK: - Comparison

  func testComparison() throws {
    XCTAssertLessThan(Cartridge.Location(address: 0x4000, bank: 1), Cartridge.Location(address: 0x4001, bank: 1))
    XCTAssertLessThan(Cartridge.Location(address: 0x100, bank: 0), Cartridge.Location(address: 0x101, bank: 1))
    XCTAssertLessThan(Cartridge.Location(address: 0x4000, bank: 1), Cartridge.Location(address: 0x4000, bank: 2))
    XCTAssertLessThan(Cartridge.Location(address: 0x7000, bank: 1), Cartridge.Location(address: 0x4000, bank: 2))

    // Addresses beyond a bank's edge wrap into the next bank when comparing.
    XCTAssertLessThan(Cartridge.Location(address: 0x4000, bank: 2), Cartridge.Location(address: 0x8001, bank: 1))
  }

  // MARK: - Striding

  func testStridingDoesNotChangeBanks() throws {
    let location = Cartridge.Location(address: 0, bank: 1)
    XCTAssertEqual(location.advanced(by: 0x8000).address, 0x8000)
    XCTAssertEqual(location.advanced(by: 0x8000).bank, 1)
    XCTAssertEqual(location.advanced(by: 0x9000).address, 0x9000)
    XCTAssertEqual(location.advanced(by: 0x9000).bank, 1)
  }

  func testDistanceCrossesBanks() throws {
    XCTAssertEqual(Cartridge.Location(address: 0x4000, bank: 2).distance(
                    to: Cartridge.Location(address: 0x5000, bank: 2)),
                   0x1000)
    XCTAssertEqual(Cartridge.Location(address: 0x5000, bank: 2).distance(
                    to: Cartridge.Location(address: 0x4000, bank: 2)),
                   -0x1000)
    XCTAssertEqual(Cartridge.Location(address: 0x4000, bank: 2).distance(
                    to: Cartridge.Location(address: 0x4000, bank: 3)),
                   0x4000)
  }
}
