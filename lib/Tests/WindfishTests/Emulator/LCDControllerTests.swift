import XCTest
@testable import Windfish

class LCDControllerTests: XCTestCase {
  func testInitialState() {
    let controller = LCDController()

    XCTAssertEqual(controller.read(from: LCDController.Addresses.LCDC.rawValue), 0x91)
  }
}
