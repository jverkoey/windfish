import XCTest
@testable import Windfish

class LCDControllerTests: XCTestCase {
  func testInitialState() {
    let controller = PPU(oam: OAM())

    XCTAssertEqual(controller.read(from: PPU.Addresses.LCDC.rawValue), 0b1001_0001)
    XCTAssertEqual(controller.read(from: PPU.Addresses.STAT.rawValue), 0b0000_0110)
    XCTAssertEqual(controller.ly, 0)
    XCTAssertEqual(controller.lyc, 0)
  }
}
