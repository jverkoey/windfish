import Foundation

extension UnsafeMutableRawBufferPointer {
  fileprivate subscript(index: LR35902.Address) -> UInt8 {
    get { return self[Int16(bitPattern: index)] }
    set { self[Int16(bitPattern: index)] = newValue }
  }
  fileprivate subscript(index: Int16) -> UInt8 {
    get { return self[Int(truncatingIfNeeded: index)] }
    set { self[Int(truncatingIfNeeded: index)] = newValue }
  }
}

extension PPU.PixelTransferMode {
  final class Fetcher {
    init(registers: PPU.LCDRegisters, fifo: Fifo) {
      self.registers = registers
      self.fifo = fifo
    }

    private let registers: PPU.LCDRegisters
    private let fifo: Fifo

    private(set) var tileMapAddress: LR35902.Address = 0
    private(set) var tileDataAddress: PPU.TileDataAddress = .x8000
    private(set) var tileMapAddressOffset: LR35902.Address = 0
    private(set) var tilePixelY: Int16 = 0
    private(set) var tickAlternator = false
    enum State {
      // Background fetching
      case readTileNumber
      case readData0
      case readData1
      case pushToFifo
      // Sprite fetching
      case readSpriteTileNumber
      case readSpriteFlags
      case readSpriteData0
      case readSpriteData1
      case overlaySpriteOnFifo
    }
    private(set) var state: State = .readTileNumber
    private(set) var tileIndex: UInt8 = 0
    private(set) var data0: UInt8 = 0
    private(set) var data1: UInt8 = 0
    private(set) var sprite: OAM.Sprite?
    private(set) var spriteTilePixelY: Int16 = 0

    func isFetchingSprite() -> Bool {
      return state == .readSpriteTileNumber
        || state == .readSpriteFlags
        || state == .readSpriteData0
        || state == .readSpriteData1
        || state == .overlaySpriteOnFifo
    }

    func startSprite(_ sprite: OAM.Sprite, y: UInt8) {
      self.sprite = sprite
      state = .readSpriteTileNumber

      // It's possible to interrupt the fetcher mid-cycle, so we re-align timing by resetting the tickAlternator to
      // its initial state.
      tickAlternator = false
      // Compute the upper-left corner of the sprite in order to calculate the intersection of ly with the sprite.
      // - 2.8.2 "Sprites": https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
      let spriteTopLeftY = sprite.y - 16
      let spriteTilePixelY = Int16(truncatingIfNeeded: y - spriteTopLeftY)

      if sprite.yflip {
        // Flipping the y-value is equivalent to a bit complement masked to the appropriate number of bits (4 for a
        // height of 16, 3 for a height of 8).
        switch registers.spriteSize {
        case .x8x16:
          // 0  0b0000 15 0b1111
          // 1  0b0001 14 0b1110
          // 2  0b0010 13 0b1101
          // 3  0b0011 12 0b1100
          // 4  0b0100 11 0b1011
          // 5  0b0101 10 0b1010
          // 6  0b0110  9 0b1001
          // 7  0b0111  8 0b1000
          self.spriteTilePixelY = (~spriteTilePixelY) & 0b1111
        case .x8x8:
          // 0  0b0000 7 0b0111
          // 1  0b0001 6 0b0110
          // 2  0b0010 5 0b0101
          // 3  0b0011 4 0b0100
          self.spriteTilePixelY = (~spriteTilePixelY) & 0b0111
        }
      } else {
        self.spriteTilePixelY = spriteTilePixelY
      }
      precondition(self.spriteTilePixelY >= 0 && self.spriteTilePixelY < registers.spriteSize.height())
    }

    /** Prepares the fetcher to start fetching a new line of pixels. */
    func start(tileMapAddress: PPU.TileMapAddress, tileDataAddress: PPU.TileDataAddress, x: UInt8, y: UInt8) {
      let wideX = UInt16(truncatingIfNeeded: x)
      let wideY = UInt16(truncatingIfNeeded: y)

      tickAlternator = false
      state = .readTileNumber
      self.tileMapAddress = tileMapAddress.address + (wideY / PPU.PixelsPerTile) * PPU.TilesPerRow
      self.tileDataAddress = tileDataAddress
      tileMapAddressOffset = wideX / PPU.PixelsPerTile
      tilePixelY = Int16(bitPattern: wideY % PPU.PixelsPerTile)
      fifo.clear()
    }

    func tick() {
      // Fetcher operates on a 2 t-cycle clock speed.
      // - "The Ultimate Game Boy Talk (33c3)": https://youtu.be/HyzD8pNlpwI?t=3054
      tickAlternator = !tickAlternator

      // pushToFifo fires on every t-cycle; all other stages fire on every other t-cycle.
      if state != .pushToFifo && tickAlternator {
        return
      }

      switch state {
      case .readTileNumber:
        tileIndex = registers.tileMap[tileMapAddress + tileMapAddressOffset - PPU.tileMapRegion.lowerBound]
        state = .readData0

      case .readData0:
        data0 = getBackgroundTileData(tileIndex: tileIndex, byte: 0)
        state = .readData1

      case .readData1:
        data1 = getBackgroundTileData(tileIndex: tileIndex, byte: 1)

        // The existence of a distinct pushToFifo state is somewhat ambiguous, as both of the canonical references on
        // PPU timing seem to imply that there are only 6 t-cycles for a given block of 8 pixels.
        // - http://blog.kevtris.org/blogfiles/Nitty%20Gritty%20Gameboy%20VRAM%20Timing.txt
        // - https://youtu.be/HyzD8pNlpwI?t=3087
        // It's unclear when the fifo is updated, but treating it as a separate state causes the mooneye
        // acceptance/ppu/intr_2_0_timing test to fail due to an additional cycle. Instead, we fallthrough directly
        // to pushToFifo after reading data1. If the fifo is stalled, then additional t-cycles will be consumed until
        // the fifo has capacity again.
        state = .pushToFifo
        fallthrough

      case .pushToFifo:
        if fifo.count > 8 {
          // Fetcher stalls when the fifo doesn't have enough space to push a new block of 8 pixels.
          // - "The Ultimate Game Boy Talk (33c3)": https://youtu.be/HyzD8pNlpwI?t=3074
          break
        }
        let backgroundPalette = registers.backgroundPalette

        for i: UInt8 in 0...7 {
          let bitMask: UInt8 = 1 << (7 - i)
          let lsb: UInt8 = ((data0 & bitMask) > 0) ? 0b01 : 0
          let msb: UInt8 = ((data1 & bitMask) > 0) ? 0b10 : 0
          fifo.queuePixel(.init(colorIndex: msb | lsb, palette: backgroundPalette, bgPriority: 0))
        }
        tileMapAddressOffset = (tileMapAddressOffset + 1) % PPU.TilesPerRow
        state = .readTileNumber

      // TODO: Break the sprite fifo out to a separate fetcher so that the bg fetcher and sprite fetcher can
      // interleave.

      // Both of the following states are no-ops because we've already snapshotted the sprite data in the OAM search
      // and OAM writes are locked down during pixel transfer mode, so we don't need to read these values again.
      // TODO: Are these t-cycle nops required?
      case .readSpriteTileNumber: state = .readSpriteFlags
      case .readSpriteFlags:      state = .readSpriteData0

      case .readSpriteData0:
        data0 = getSpriteTileData(byte: 0)
        state = .readSpriteData1

      case .readSpriteData1:
        data1 = getSpriteTileData(byte: 1)
        state = .overlaySpriteOnFifo

      case .overlaySpriteOnFifo:
        guard let sprite = sprite else {
          fatalError()
        }
        if sprite.x > 0 {
          let palette: PPU.Palette
          switch sprite.palette {
          case .obj0pal:
            palette = registers.objectPallete0
          case .obj1pal:
            palette = registers.objectPallete1
          }
          precondition(fifo.count >= 8)
          let offset = (sprite.x < 8) ? Int(truncatingIfNeeded: 8 - sprite.x) : 0
          for i: Int in offset...7 {
            let pixel = fifo[i]

            if pixel.bgPriority == 1 {
              continue
            }

            let bitIndex = sprite.xflip ? i : (7 - i)
            let bitMask: UInt8 = 1 << UInt8(truncatingIfNeeded: bitIndex)
            let lsb: UInt8 = ((data0 & bitMask) > 0) ? 0b01 : 0
            let msb: UInt8 = ((data1 & bitMask) > 0) ? 0b10 : 0
            let spriteColorIndex = msb | lsb

            let existingColorIndex = fifo[i].colorIndex
            if (sprite.priority && existingColorIndex == 0) || !sprite.priority && spriteColorIndex != 0 {
              fifo[i] = .init(colorIndex: spriteColorIndex, palette: palette, bgPriority: 1)
            }
          }
        }
        state = .readTileNumber
      }
    }

    private func getBackgroundTileData(tileIndex: UInt8, byte: Int16) -> UInt8 {
      // For simplicity's sake, we always treat the tile index as a signed 16 bit value. We can do this because the
      // tile index can never, by definition, be greater than 255, so there's no risk of the unsigned tile index
      // becoming negative.
      let dataIndex: Int16
      switch tileDataAddress {
      // Converting from UInt8 to Int16 requires a bit of a dance depending on the intended representation of the
      // UInt8's value. When it's actually a signed value, we need to be careful that extending the size of the byte
      // also extends the sign bit. Doing so requires that we bit-pattern cast to an Int8 and then extend the size to
      // an Int16.
      case .x8800: dataIndex = Int16(truncatingIfNeeded: Int8(bitPattern: tileIndex))
      // Extending an unsigned byte is a bit more straightforward, as we can directly extend the type to a UInt16.
      case .x8000: dataIndex = Int16(bitPattern: UInt16(truncatingIfNeeded: tileIndex))
      }
      // Each Tile occupies 16 bytes, where each 2 bytes represent a line:
      // Byte 0-1  First Line (Upper 8 pixels)
      // Byte 2-3  Next Line
      // etc.
      // - https://gbdev.io/pandocs/#video-display
      // tilePixelY determines which byte pair we want to read, and is doubled to account for the two-byte size of a
      // single line.
      let tileOffset = dataIndex &* PPU.BytesPerTile
      let tileLineOffset = tilePixelY &* PPU.BytesPerLine
      let address = tileDataAddress.baseAddress &+ UInt16(bitPattern: tileOffset + tileLineOffset + byte)
      return registers.tileData[Int(truncatingIfNeeded: address - PPU.tileDataRegion.lowerBound)]
    }

    private func getSpriteTileData(byte: Int16) -> UInt8 {
      guard let sprite = sprite else {
        fatalError()
      }
      let dataIndex = Int16(bitPattern: UInt16(truncatingIfNeeded: sprite.tile))
      let tileOffset = dataIndex &* PPU.BytesPerTile
      let tileLineOffset = spriteTilePixelY &* PPU.BytesPerLine
      let address = 0x8000 &+ UInt16(bitPattern: tileOffset + tileLineOffset + byte)
      return registers.tileData[Int(truncatingIfNeeded: address - PPU.tileDataRegion.lowerBound)]
    }
  }
}
