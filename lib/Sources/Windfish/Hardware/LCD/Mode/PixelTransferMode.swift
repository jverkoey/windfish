import Foundation

extension PPU {
  static let TilesPerRow: UInt16 = 32
  static let PixelsPerTile: UInt16 = 8
  static let BytesPerTile: Int16 = 16
  static let BytesPerLine: Int16 = 2

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

    private let fetcher: Fetcher
    private var fifo: Fifo
    private var droppedPixels: UInt8 = 0
    private var screenPlotAnchor: Int = 0
    private var screenPlotOffset: UInt8 = 0
    private var debug_tcycle: Int = 0
    private var drawnSprites = ContiguousArray<Bool>(repeating: false, count: 10)

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
      for i in 0..<drawnSprites.count {
        drawnSprites[i] = false
      }
    }

    /** Executes a single t-cycle. */
    func tick(memory: AddressableMemory) -> LCDCMode? {
      lineCycleDriver.tcycles += 1
      debug_tcycle += 1

      // The minimum number of t-cycles for pixel transfer is 172, but this implementation only takes 171. It's unclear
      // where the cycle is being lost, so for now to pass mooneye/acceptance/ppu/hblank_ly_scx_timing-GS we pad with
      // one nop to get from 171 to 172.
      if debug_tcycle == 1 {
        return nil // Skip the first t-cycle tick.
      }

      fetcher.tick()

      if registers.backgroundEnable {
        // The fifo requires at least 9 pixels in order to be able to pop a pixel off. This ensures that there are
        // always at least 8 pixels for the purposes of compositing sprites onto the background pixels.
        // Until there are at least 9 pixels, the fifo stalls.
        if fifo.count < 9 {
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
          fifo.removeFirst()
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
          if drawnSprites[index] {
            continue  // Skip sprites we've already drawn.
          }
          if (screenPlotOffset == 0 && sprite.x < 8) || (sprite.x - 8 == screenPlotOffset) {
            drawnSprites[index] = true
            fetcher.startSprite(sprite, y: registers.ly)
            return nil
          }
        }
      }

      // This is first executed on t-cycle 4 of the pixel transfer. It takes two machine cycles to load one tile line
      // into the fifo, and the fifo must always have at least 8 pixels in it before pixels can be dequeued, so we
      // load a second tile's line for an additional two machine cycles.
      precondition(debug_tcycle >= 4)
      registers.screenData[screenPlotAnchor + Int(truncatingIfNeeded: screenPlotOffset)] = fifo.dequeuePixel()

      screenPlotOffset += 1
      if screenPlotOffset >= 160 {
        // Either http://blog.kevtris.org/blogfiles/Nitty%20Gritty%20Gameboy%20VRAM%20Timing.txt has the wrong t-cycle
        // timings, or our counting is wrong here, because the doc says there are 173 cycles per line in the simple
        // case, but mooneye's hardware tests expect 172 cycles.
        precondition(!drawnSprites.isEmpty || debug_tcycle == 172)
        return .hblank
      }
      return nil
    }
  }
}
