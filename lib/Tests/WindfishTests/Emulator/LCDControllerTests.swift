import XCTest
@testable import Windfish

class LCDControllerTests: XCTestCase {
  func testInitialState() {
    let controller = LCDController()

    XCTAssertEqual(controller.read(from: LCDController.Addresses.LCDC.rawValue), 0b1001_0001)
    XCTAssertEqual(controller.read(from: LCDController.Addresses.STAT.rawValue), 0b0000_0110)
    XCTAssertEqual(controller.ly, 0)
    XCTAssertEqual(controller.lyc, 0)
  }
}
