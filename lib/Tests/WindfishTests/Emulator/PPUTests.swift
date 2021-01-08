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
          } else if cycle <= 64 {
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
    let fifo = PPU.PixelTransferMode.Fifo()
    let fetcher = PPU.PixelTransferMode.Fetcher(registers: registers, fifo: fifo)

    for tileDataAddress: PPU.TileDataAddress in [.x8000, .x8800] {
      for tileMapAddress: PPU.TileMapAddress in [.x9800, .x9C00] {
        fetcher.start(tileMapAddress: tileMapAddress, tileDataAddress: tileDataAddress, x: 0, y: 0)

        XCTAssertEqual(fetcher.tileMapAddress, tileMapAddress.address)
        XCTAssertEqual(fetcher.tileDataAddress, tileDataAddress)
        XCTAssertEqual(fetcher.tileMapAddressOffset, 0)
        XCTAssertEqual(fetcher.tilePixelY, 0)
      }
    }
  }

  func testXValues() {
    let fifo = PPU.PixelTransferMode.Fifo()
    let fetcher = PPU.PixelTransferMode.Fetcher(registers: registers, fifo: fifo)

    for tileMapAddress: PPU.TileMapAddress in [.x9800, .x9C00] {
      // Edge of tile 0/1
      fetcher.start(tileMapAddress: tileMapAddress, tileDataAddress: .x8000, x: 7, y: 0)

      XCTAssertEqual(fetcher.tileMapAddress, tileMapAddress.address)
      XCTAssertEqual(fetcher.tileMapAddressOffset, 0)
      XCTAssertEqual(fetcher.tilePixelY, 0)

      // Start of tile 1
      fetcher.start(tileMapAddress: tileMapAddress, tileDataAddress: .x8000, x: 8, y: 0)

      XCTAssertEqual(fetcher.tileMapAddress, tileMapAddress.address)
      XCTAssertEqual(fetcher.tileMapAddressOffset, 1)
      XCTAssertEqual(fetcher.tilePixelY, 0)

      // Start of tile 2
      fetcher.start(tileMapAddress: tileMapAddress, tileDataAddress: .x8000, x: 16, y: 0)

      XCTAssertEqual(fetcher.tileMapAddress, tileMapAddress.address)
      XCTAssertEqual(fetcher.tileMapAddressOffset, 2)
      XCTAssertEqual(fetcher.tilePixelY, 0)
    }
  }

  func testYValues() {
    let fifo = PPU.PixelTransferMode.Fifo()
    let fetcher = PPU.PixelTransferMode.Fetcher(registers: registers, fifo: fifo)

    for tileMapAddress: PPU.TileMapAddress in [.x9800, .x9C00] {
      // Tile 0, row 1
      fetcher.start(tileMapAddress: tileMapAddress, tileDataAddress: .x8000, x: 0, y: 1)

      XCTAssertEqual(fetcher.tileMapAddress, tileMapAddress.address)
      XCTAssertEqual(fetcher.tileMapAddressOffset, 0)
      XCTAssertEqual(fetcher.tilePixelY, 1)

      // Tile 1, row 0
      fetcher.start(tileMapAddress: tileMapAddress, tileDataAddress: .x8000, x: 0, y: 8)

      XCTAssertEqual(fetcher.tileMapAddress, tileMapAddress.address + 32)
      XCTAssertEqual(fetcher.tileMapAddressOffset, 0)
      XCTAssertEqual(fetcher.tilePixelY, 0)

      // Tile 2, row 2
      fetcher.start(tileMapAddress: tileMapAddress, tileDataAddress: .x8000, x: 0, y: 18)

      XCTAssertEqual(fetcher.tileMapAddress, tileMapAddress.address + 32 * 2)
      XCTAssertEqual(fetcher.tileMapAddressOffset, 0)
      XCTAssertEqual(fetcher.tilePixelY, 2)
    }
  }

  struct StateMachineState {
    var tileMapAddress: LR35902.Address
    var tileDataAddress: PPU.TileDataAddress
    var tileMapAddressOffset: UInt16
    var tilePixelY: Int16
    var tickAlternator: Bool
    var state: PPU.PixelTransferMode.Fetcher.State
    var tileIndex: UInt8
    var data0: UInt8
    var data1: UInt8
    var pixels: [PPU.PixelTransferMode.Pixel]

    func assertEqual(_ state: PPU.PixelTransferMode.Fetcher, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
      XCTAssertEqual(tileMapAddress, state.tileMapAddress,              "tileMapAddress mismatch \(message)", file: file, line: line)
      XCTAssertEqual(tileDataAddress, state.tileDataAddress,            "tileDataAddress mismatch \(message)", file: file, line: line)
      XCTAssertEqual(tileMapAddressOffset, state.tileMapAddressOffset,  "tileMapAddressOffset mismatch \(message)", file: file, line: line)
      XCTAssertEqual(tilePixelY, state.tilePixelY,                      "tilePixelY mismatch \(message)", file: file, line: line)
      XCTAssertEqual(tickAlternator, state.tickAlternator,              "tickAlternator mismatch \(message)", file: file, line: line)
      XCTAssertEqual(self.state, state.state,                           "state mismatch \(message)", file: file, line: line)
      XCTAssertEqual(tileIndex, state.tileIndex,                        "tileIndex mismatch \(message)", file: file, line: line)
      XCTAssertEqual(data0, state.data0,                                "data0 mismatch \(message)", file: file, line: line)
      XCTAssertEqual(data1, state.data1,                                "data1 mismatch \(message)", file: file, line: line)
    }
  }

  func testStateMachineLines() {
    for ly in [
      0, 1, 7,  // ytile: 0
      8,        // ytile: 1
      16,       // ytile: 2
        26,     // ytile: 3
    ] {
      let assertContext = "ly: \(ly)"
      registers.tileMap[0 + (ly / 8) * 32] = 0xab
      registers.tileMap[1 + (ly / 8) * 32] = 0xcd
      registers.tileMap[2 + (ly / 8) * 32] = 0xef
      registers.tileData[(ly % 8) * 2 + 0xab * 16]     = 0b1010_1010
      registers.tileData[(ly % 8) * 2 + 0xab * 16 + 1] = 0b0101_0101
      registers.tileData[(ly % 8) * 2 + 0xcd * 16]     = 0b0101_0101
      registers.tileData[(ly % 8) * 2 + 0xcd * 16 + 1] = 0b1010_1010
      registers.tileData[(ly % 8) * 2 + 0xef * 16]     = 0b0111_1000
      registers.tileData[(ly % 8) * 2 + 0xef * 16 + 1] = 0b0001_1110
      let fifo = PPU.PixelTransferMode.Fifo()
      let fetcher = PPU.PixelTransferMode.Fetcher(registers: registers, fifo: fifo)

      fetcher.start(tileMapAddress: .x9800, tileDataAddress: .x8000, x: 0, y: UInt8(truncatingIfNeeded: ly))

      // Initial state
      var state = StateMachineState(
        tileMapAddress: 0x9800 + UInt16(truncatingIfNeeded: (ly / 8) * 32),
        tileDataAddress: .x8000,
        tileMapAddressOffset: 0,
        tilePixelY: Int16(truncatingIfNeeded: ly % 8),
        tickAlternator: false,
        state: .readTileNumber,
        tileIndex: 0,
        data0: 0,
        data1: 0,
        pixels: []
      )
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)

      // MARK: Push 8 pixels of tile 0

      // read tile number
      fetcher.tick()
      state.tickAlternator = true
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
      fetcher.tick()
      state.tickAlternator = false
      state.tileIndex = 0xab
      state.state = .readData0
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)

      // Read data 0
      fetcher.tick()
      state.tickAlternator = true
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
      fetcher.tick()
      state.tickAlternator = false
      state.data0 = 0b1010_1010
      state.state = .readData1
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)

      // Read data 1
      fetcher.tick()
      state.tickAlternator = true
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
      fetcher.tick()
      state.tickAlternator = false
      state.data1 = 0b0101_0101
      state.state = .pushToFifo
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)

      // Push to fifo
      fetcher.tick()
      state.tickAlternator = true
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
      fetcher.tick()
      state.tickAlternator = false
      state.state = .readTileNumber
      state.tileMapAddressOffset += 1
      state.pixels = [
        0b01, 0b10, 0b01, 0b10,
        0b01, 0b10, 0b01, 0b10,
      ].map { .init(colorIndex: $0, palette: registers.backgroundPalette, spritePriority: 0, bgPriority: 0)}
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)

      // MARK: Push 8 pixels of tile 1

      // read tile number
      fetcher.tick()
      state.tickAlternator = true
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
      fetcher.tick()
      state.tickAlternator = false
      state.tileIndex = 0xcd
      state.state = .readData0
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)

      // Read data 0
      fetcher.tick()
      state.tickAlternator = true
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
      fetcher.tick()
      state.tickAlternator = false
      state.data0 = 0b0101_0101
      state.state = .readData1
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)

      // Read data 1
      fetcher.tick()
      state.tickAlternator = true
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
      fetcher.tick()
      state.tickAlternator = false
      state.data1 = 0b1010_1010
      state.state = .pushToFifo
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)

      // Push to fifo
      fetcher.tick()
      state.tickAlternator = true
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
      fetcher.tick()
      state.tickAlternator = false
      state.state = .readTileNumber
      state.tileMapAddressOffset += 1
      state.pixels.append(contentsOf: [
        0b10, 0b01, 0b10, 0b01,
        0b10, 0b01, 0b10, 0b01,
      ].map { .init(colorIndex: $0, palette: registers.backgroundPalette, spritePriority: 0, bgPriority: 0)})
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)

      // MARK: Stall on 8 pixels of tile 2 due to fifo not being dequeued

      // read tile number
      fetcher.tick()
      state.tickAlternator = true
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
      fetcher.tick()
      state.tickAlternator = false
      state.tileIndex = 0xef
      state.state = .readData0
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)

      // Read data 0
      fetcher.tick()
      state.tickAlternator = true
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
      fetcher.tick()
      state.tickAlternator = false
      state.data0 = 0b0111_1000
      state.state = .readData1
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)

      // Read data 1
      fetcher.tick()
      state.tickAlternator = true
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
      fetcher.tick()
      state.tickAlternator = false
      state.data1 = 0b0001_1110
      state.state = .pushToFifo
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)

      // Push to fifo
      fetcher.tick()
      state.tickAlternator = true
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
      fetcher.tick()
      state.tickAlternator = false
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)

      // MARK: Continue stalling even with 7 pixels dequeued

      // Clear the first 7 pixels.
      fifo.pixels.removeFirst(7)
      state.pixels.removeFirst(7)

      // Still stalled
      fetcher.tick()
      state.tickAlternator = true
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
      fetcher.tick()
      state.tickAlternator = false
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)

      // MARK: Push 8 pixels of tile 2 now that fifo is free

      // Clear one more pixel.
      fifo.pixels.removeFirst()
      state.pixels.removeFirst()

      // Fetcher no longer stalled
      fetcher.tick()
      state.tickAlternator = true
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
      fetcher.tick()
      state.tickAlternator = false
      state.state = .readTileNumber
      state.tileMapAddressOffset += 1
      state.pixels.append(contentsOf: [
        0b00, 0b01, 0b01, 0b11,
        0b11, 0b10, 0b10, 0b00,
      ].map { .init(colorIndex: $0, palette: registers.backgroundPalette, spritePriority: 0, bgPriority: 0)})
      state.assertEqual(fetcher, assertContext)
      XCTAssertEqual(fifo.pixels, state.pixels, assertContext)
    }
  }
}
