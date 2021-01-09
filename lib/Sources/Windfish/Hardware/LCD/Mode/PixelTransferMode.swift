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

extension PPU {
  private static let TilesPerRow: UInt16 = 32
  private static let PixelsPerTile: UInt16 = 8
  private static let BytesPerTile: Int16 = 16
  private static let BytesPerLine: Int16 = 2

  final class PixelTransferMode: PPUMode {
    init(registers: LCDRegisters, lineCycleDriver: LineCycleDriver) {
      self.registers = registers
      self.lineCycleDriver = lineCycleDriver
      self.fifo = Fifo()
      self.fetcher = Fetcher(registers: registers, fifo: fifo)
    }

    private let registers: LCDRegisters
    private let lineCycleDriver: LineCycleDriver

    var intersectedOAMs: [OAM.Sprite] = []

    struct Pixel: Equatable {
      let colorIndex: UInt8
      let palette: Palette
      let spritePriority: UInt8
      let bgPriority: UInt8
    }
    final class Fifo {
      var pixels: [Pixel] = []

      func dequeuePixel() -> UInt8 {
        let pixel = pixels.removeFirst()
        return pixel.palette[Int(truncatingIfNeeded: pixel.colorIndex)]
      }
    }
    final class Fetcher {
      init(registers: LCDRegisters, fifo: Fifo) {
        self.registers = registers
        self.fifo = fifo
      }

      private let registers: LCDRegisters
      private let fifo: Fifo

      private(set) var tileMapAddress: LR35902.Address = 0
      private(set) var tileDataAddress: TileDataAddress = .x8000
      private(set) var tileMapAddressOffset: UInt16 = 0
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
      func start(tileMapAddress: TileMapAddress, tileDataAddress: TileDataAddress, x: UInt8, y: UInt8) {
        let wideX = UInt16(truncatingIfNeeded: x)
        let wideY = UInt16(truncatingIfNeeded: y)

        tickAlternator = false
        state = .readTileNumber
        self.tileMapAddress = tileMapAddress.address + (wideY / PPU.PixelsPerTile) * PPU.TilesPerRow
        self.tileDataAddress = tileDataAddress
        tileMapAddressOffset = wideX / PPU.PixelsPerTile
        tilePixelY = Int16(bitPattern: wideY % PPU.PixelsPerTile)
        fifo.pixels.removeAll()
      }

      func tick() {
        // Fetcher operates on a 2 t-cycle clock speed.
        // - "The Ultimate Game Boy Talk (33c3)": https://youtu.be/HyzD8pNlpwI?t=3054
        tickAlternator = !tickAlternator
        if tickAlternator {
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
          if fifo.pixels.count > 8 {
            // Fetcher stalls when the fifo doesn't have enough space to push a new block of 8 pixels.
            // - "The Ultimate Game Boy Talk (33c3)": https://youtu.be/HyzD8pNlpwI?t=3074
            break
          }

          for i: UInt8 in stride(from: 7, through: 0, by: -1) {
            let bitMask: UInt8 = 1 << i
            let lsb: UInt8 = ((data0 & bitMask) > 0) ? 0b01 : 0
            let msb: UInt8 = ((data1 & bitMask) > 0) ? 0b10 : 0
            fifo.pixels.append(.init(colorIndex: msb | lsb, palette: registers.backgroundPalette,
                                     spritePriority: 0, bgPriority: 0))
          }
          tileMapAddressOffset = (tileMapAddressOffset + 1) % PPU.TilesPerRow
          state = .readTileNumber

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
          guard sprite.x > 0 else {
            // Nothing to draw here, jump immediately to the next state.
            state = .readData0
            break
          }
          let palette: Palette
          switch sprite.palette {
          case .obj0pal:
            palette = registers.objectPallete0
          case .obj1pal:
            palette = registers.objectPallete1
          }
          let offset = (sprite.x < 8) ? Int(truncatingIfNeeded: 8 - sprite.x) : 0
          for i: Int in offset...7 {
            let pixel = fifo.pixels[i]

            if pixel.spritePriority == 1 {
              continue
            }

            let bitIndex = sprite.xflip ? i : (7 - i)
            let bitMask: UInt8 = 1 << UInt8(truncatingIfNeeded: bitIndex)
            let lsb: UInt8 = ((data0 & bitMask) > 0) ? 0b01 : 0
            let msb: UInt8 = ((data1 & bitMask) > 0) ? 0b10 : 0
            let spriteColorIndex = msb | lsb

            let pixelColorIndex = fifo.pixels[i].colorIndex
            if (sprite.priority && pixelColorIndex == 0) || !sprite.priority && spriteColorIndex != 0 {
              fifo.pixels[i] = .init(colorIndex: spriteColorIndex, palette: palette, spritePriority: 1, bgPriority: 0)
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
    private let fetcher: Fetcher
    private var fifo: Fifo
    private var droppedPixels: UInt8 = 0
    private var screenPlotAnchor: Int = 0
    private var screenPlotOffset: UInt8 = 0
    private var debug_tcycle: Int = 0
    private var drawnSprites = Set<Int>()

    /** Starts the mode. */
    func start() {
      // Note that we don't reset lineCycleDriver.cycles here because we're continuing to cycle through this ly.

      // TODO: Check registers.backgroundEnable and registers.windowEnable
      precondition(registers.backgroundEnable)  // Disabled behavior not currently implemented.
//      precondition(!registers.windowEnable)  // Window not currently implemented.

      // FIFO+Fetcher logic
      fetcher.start(tileMapAddress: registers.backgroundTileMapAddress,
                    tileDataAddress: registers.tileDataAddress,
                    x: registers.scx,
                    y: lineCycleDriver.scanline &+ registers.scy)
      droppedPixels = 0
      screenPlotAnchor = Int(truncatingIfNeeded: lineCycleDriver.scanline) * PPU.screenSize.width
      screenPlotOffset = 0
      debug_tcycle = 0
      drawnSprites.removeAll(keepingCapacity: true)
    }

    /** Executes a single t-cycle. */
    func tick(memory: AddressableMemory) -> LCDCMode? {
      lineCycleDriver.tcycles += 1
      debug_tcycle += 1

      fetcher.tick()

      if registers.backgroundEnable {
        // The fifo requires at least 9 pixels in order to be able to pop a pixel off. This ensures that there are
        // always at least 8 pixels for the purposes of compositing sprites onto the background pixels.
        // Until there are at least 9 pixels, the fifo stalls.
        if fifo.pixels.count <= 8 {
          return nil
        }

        // Scrolling is implemented by dropping pixels from the fifo up until the scx.
        // - "The Ultimate Game Boy Talk (33c3)": https://youtu.be/HyzD8pNlpwI?t=3104
        //
        // "The program running on the GB CPU can still change various registers like SCX and SCY when a line is being
        // "drawn to the screen. (I.e. during mode 3.) At least one officially released game makes heavy used of that:
        // Prehistorik Man which is using it in its intro to draw text using palette changes, and probably in some
        // places in the gameplay as well. Not to mention demoscene demos, which (ab)use this a lot, for example Mental
        // Respirator and 20Y, which use this for things like wobbly image stretching and other special effects."
        // - http://forums.nesdev.com/viewtopic.php?f=20&t=10771#p122197
        // This is why we use registers.scx directly here rather than a cached value at the start of the line.
        if droppedPixels < registers.scx % UInt8(truncatingIfNeeded: PPU.PixelsPerTile) {
          fifo.pixels.removeFirst()
          droppedPixels += 1

          // Because scx can change mid-line, we can't use the simple (173 + (xscroll % 7)) formula outlined in
          // http://blog.kevtris.org/blogfiles/Nitty%20Gritty%20Gameboy%20VRAM%20Timing.txt
          // Instead, we offset the tcycle counter for each cycle spent dropping a pixel.
          debug_tcycle -= 1
          return nil
        }

        // TODO: Check if we need to start fetching the window.
      }

      if registers.objEnable {
        if fetcher.isFetchingSprite() {
          return nil  // Stall until we've finished fetching the sprite.
        }

        // When a sprite is detected, the fetcher switches temporarily to a sprite fetch mode
        // - "The Ultimate Game Boy Talk (33c3)": https://youtu.be/HyzD8pNlpwI?t=3179
        for (index, sprite) in intersectedOAMs.enumerated() {
          if drawnSprites.contains(index) {
            continue  // Skip sprites we've already drawn.
          }
          if screenPlotOffset == 0 && sprite.x < 8 {
            drawnSprites.insert(index)
            fetcher.startSprite(sprite, y: registers.ly)
          } else if sprite.x - 8 == screenPlotOffset {
            drawnSprites.insert(index)
            fetcher.startSprite(sprite, y: registers.ly)
            return nil
          }
        }
      }

      // This is first executed on cycle 4 of the pixel transfer. It takes two machine cycles to load one tile line
      // into the fifo, and the fifo must always have at least 8 pixels in it before pixels can be dequeued, so we
      // load a second tile's line for an additional two machine cycles.
      registers.screenData[screenPlotAnchor + Int(truncatingIfNeeded: screenPlotOffset)] = fifo.dequeuePixel()

      screenPlotOffset += 1
      if screenPlotOffset >= 160 {
        // Either http://blog.kevtris.org/blogfiles/Nitty%20Gritty%20Gameboy%20VRAM%20Timing.txt has the wrong t-cycle
        // timings, or our counting is wrong here, because the doc says there are 173 cycles per line in the simple
        // case, but mooneye's hardware tests expect ~171 cycles.
        precondition(!drawnSprites.isEmpty || debug_tcycle == 171)
        registers.requestHBlankInterruptIfNeeded(memory: memory)
        return .hblank
      }
      return nil
    }
  }
}
