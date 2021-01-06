import XCTest
@testable import Windfish

class PPUTests: XCTestCase {
  func testInitialState() {
    let controller = PPU(oam: OAM())

    XCTAssertEqual(controller.read(from: PPU.Addresses.LCDC.rawValue), 0b1001_0001)
    XCTAssertEqual(controller.read(from: PPU.Addresses.STAT.rawValue), 0b0000_0110)
    XCTAssertEqual(controller.registers.ly, 0)
    XCTAssertEqual(controller.registers.lyc, 0)
  }
}

class PPUFetcherTests: XCTestCase {
  func testZero() {
    let fetcher = PPU.PixelTransferMode.Fetcher()

    // Zero
    for tileMapAddress: PPU.TileMapAddress in [.x9800, .x9C00] {
      fetcher.start(tileMapAddress: tileMapAddress, tileDataAddress: .x8000, x: 0, y: 0)

      XCTAssertEqual(fetcher.tileMapAddress, tileMapAddress.address)
      XCTAssertEqual(fetcher.tileDataAddress, .x8000)
      XCTAssertEqual(fetcher.tileMapAddressOffset, 0)
      XCTAssertEqual(fetcher.tilePixelY, 0)
    }
  }

  func testXValues() {
    let fetcher = PPU.PixelTransferMode.Fetcher()

    for tileMapAddress: PPU.TileMapAddress in [.x9800, .x9C00] {
      // Edge of tile 0/1
      fetcher.start(tileMapAddress: tileMapAddress, tileDataAddress: .x8000, x: 7, y: 0)

      XCTAssertEqual(fetcher.tileMapAddress, tileMapAddress.address)
      XCTAssertEqual(fetcher.tileDataAddress, .x8000)
      XCTAssertEqual(fetcher.tileMapAddressOffset, 0)
      XCTAssertEqual(fetcher.tilePixelY, 0)

      // Start of tile 1
      fetcher.start(tileMapAddress: tileMapAddress, tileDataAddress: .x8000, x: 8, y: 0)

      XCTAssertEqual(fetcher.tileMapAddress, tileMapAddress.address)
      XCTAssertEqual(fetcher.tileDataAddress, .x8000)
      XCTAssertEqual(fetcher.tileMapAddressOffset, 1)
      XCTAssertEqual(fetcher.tilePixelY, 0)

      // Start of tile 2
      fetcher.start(tileMapAddress: tileMapAddress, tileDataAddress: .x8000, x: 16, y: 0)

      XCTAssertEqual(fetcher.tileMapAddress, tileMapAddress.address)
      XCTAssertEqual(fetcher.tileDataAddress, .x8000)
      XCTAssertEqual(fetcher.tileMapAddressOffset, 2)
      XCTAssertEqual(fetcher.tilePixelY, 0)
    }
  }

  func testYValues() {
    let fetcher = PPU.PixelTransferMode.Fetcher()

    for tileMapAddress: PPU.TileMapAddress in [.x9800, .x9C00] {
      // Tile 0, row 1
      fetcher.start(tileMapAddress: tileMapAddress, tileDataAddress: .x8000, x: 0, y: 1)

      XCTAssertEqual(fetcher.tileMapAddress, tileMapAddress.address)
      XCTAssertEqual(fetcher.tileDataAddress, .x8000)
      XCTAssertEqual(fetcher.tileMapAddressOffset, 0)
      XCTAssertEqual(fetcher.tilePixelY, 1)

      // Tile 1, row 0
      fetcher.start(tileMapAddress: tileMapAddress, tileDataAddress: .x8000, x: 0, y: 8)

      XCTAssertEqual(fetcher.tileMapAddress, tileMapAddress.address + 32)
      XCTAssertEqual(fetcher.tileDataAddress, .x8000)
      XCTAssertEqual(fetcher.tileMapAddressOffset, 0)
      XCTAssertEqual(fetcher.tilePixelY, 0)
    }
  }
}
