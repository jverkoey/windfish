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

  func testModeTimings() {
    let controller = PPU(oam: OAM())
    let memory = TestMemory()

    // Initial state.
    XCTAssertEqual(controller.registers.lcdMode, .searchingOAM)

    for line: UInt8 in 0..<154 {
      for cycle in 1...114 {
        controller.advance(memory: memory)

        if line < 144 {
          if cycle <= 20 {
            XCTAssertEqual(controller.registers.lcdMode, .searchingOAM, "line: \(line) cycle: \(cycle)")
          } else if cycle <= 63 {
            XCTAssertEqual(controller.registers.lcdMode, .pixelTransfer, "line: \(line) cycle: \(cycle)")
          } else {
            XCTAssertEqual(controller.registers.lcdMode, .hblank, "line: \(line) cycle: \(cycle)")
          }
        } else {
          XCTAssertEqual(controller.registers.lcdMode, .vblank, "line: \(line) cycle: \(cycle)")
        }
      }
    }

    // Mode is committed one cycle delayed
    XCTAssertEqual(controller.registers.lcdMode, .vblank)
    controller.advance(memory: memory)
    XCTAssertEqual(controller.registers.lcdMode, .searchingOAM)
  }

  func testLYTimings() {
    let controller = PPU(oam: OAM())
    let memory = TestMemory()

    // Initial state.
    XCTAssertEqual(controller.registers.ly, 0)

    for line: UInt8 in 0..<154 {
      for cycle in 1...114 {
        controller.advance(memory: memory)

        if line < 153 {
          if cycle < 114 {
            // Still on the same line.
            XCTAssertEqual(controller.registers.ly, line, "line: \(line) cycle: \(cycle)")
          } else {
            // We've advanced a line.
            XCTAssertEqual(controller.registers.ly, line + 1, "line: \(line) cycle: \(cycle)")
          }
        }
        if line == 153 {
          if cycle == 1 {
            // Still on the same line.
            XCTAssertEqual(controller.registers.ly, line, "line: \(line) cycle: \(cycle)")
          } else {
            // Remainder of line is simulated as line zero.
            XCTAssertEqual(controller.registers.ly, 0, "line: \(line) cycle: \(cycle)")
          }
        }
      }
    }

    // Final state should equal initial state.
    XCTAssertEqual(controller.registers.ly, 0)
  }

  func testCoincidenceTimings() {
    for lyc: UInt8 in [0, 1, 143, 144, 152, 153] {
      let controller = PPU(oam: OAM())
      let memory = TestMemory()

      // Initial state.
      XCTAssertTrue(controller.registers.coincidence, "lyc: \(lyc)")

      controller.registers.lyc = lyc

      for line: UInt8 in 0..<154 {
        for cycle in 1...114 {
          controller.advance(memory: memory)

          if cycle == 1 {
            // Coincidence is never set on the first cycle.
            XCTAssertFalse(controller.registers.coincidence, "lyc: \(lyc) line: \(line) cycle: \(cycle)")
          } else if line < 153 {
            // Coincidence is true when the line == lyc
            if line == lyc {
              XCTAssertTrue(controller.registers.coincidence, "lyc: \(lyc) line: \(line) cycle: \(cycle)")
            } else {
              XCTAssertFalse(controller.registers.coincidence, "lyc: \(lyc) line: \(line) cycle: \(cycle)")
            }
          } else {
            if lyc == 153 {
              // ly coincidence is only set for 153 on the second cycle
              if cycle == 2 {
                XCTAssertTrue(controller.registers.coincidence, "lyc: \(lyc) line: \(line) cycle: \(cycle)")
              } else {
                XCTAssertFalse(controller.registers.coincidence, "lyc: \(lyc) line: \(line) cycle: \(cycle)")
              }
            } else if lyc == 0 {
              // ly is set to 0 on cycle 2 but it only affects coincidence starting on cycle 4.
              if cycle >= 4 {
                XCTAssertTrue(controller.registers.coincidence, "lyc: \(lyc) line: \(line) cycle: \(cycle)")
              } else {
                XCTAssertFalse(controller.registers.coincidence, "lyc: \(lyc) line: \(line) cycle: \(cycle)")
              }
            }
          }
        }
      }

      // Coincidence at end is only true for the lyc == 0 case
      if lyc == 0 {
        XCTAssertTrue(controller.registers.coincidence, "lyc: \(lyc)")
      } else {
        XCTAssertFalse(controller.registers.coincidence, "lyc: \(lyc)")
      }
    }
  }
}

class PPUFetcherTests: XCTestCase {
  var registers: PPU.LCDRegisters!

  override func setUp() {
    super.setUp()

    registers = .init()
  }

  func testZero() {
    let fetcher = PPU.PixelTransferMode.Fetcher(registers: registers)

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
    let fetcher = PPU.PixelTransferMode.Fetcher(registers: registers)

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
    let fetcher = PPU.PixelTransferMode.Fetcher(registers: registers)

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
