import Foundation

// References:
// - https://www.youtube.com/watch?v=HyzD8pNlpwI&t=29m19s
// - https://gbdev.gg8.se/wiki/articles/Video_Display#FF41_-_STAT_-_LCDC_Status_.28R.2FW.29
// - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
// - http://gameboy.mongenel.com/dmg/asmmemmap.html
// - https://hacktix.github.io/GBEDG/ppu/#the-concept-of-scanlines
// - https://blog.tigris.fr/2019/09/15/writing-an-emulator-the-first-pixel/

public final class LCDController {
  static let tileMapRegion: ClosedRange<LR35902.Address> = 0x9800...0x9FFF
  static let tileDataRegion: ClosedRange<LR35902.Address> = 0x8000...0x97FF
  static let registerRegion1: ClosedRange<LR35902.Address> = 0xFF40...0xFF45
  static let registerRegion2: ClosedRange<LR35902.Address> = 0xFF47...0xFF4B

  init(oam: OAM) {
    self.oam = oam
    self.modeOAMSearch = OAMSearchMode(oam: oam, registers: registers, lineCycleDriver: lineCycleDriver)
    self.modeVBlank = VBlankMode(registers: registers, lineCycleDriver: lineCycleDriver)
    self.modeHBlank = HBlankMode(registers: registers, lineCycleDriver: lineCycleDriver)
  }

  let oam: OAM
  let registers = LCDRegisters()
  private let modeOAMSearch: OAMSearchMode
  private let modeVBlank: VBlankMode
  private let modeHBlank: HBlankMode

  var bufferToggle = false
  public static let screenSize = (width: 160, height: 144)

  final class LineCycleDriver {
    var cycles: Int = 0
  }
  private let lineCycleDriver = LineCycleDriver()

  enum Addresses: LR35902.Address {
    case LCDC = 0xFF40
    case STAT = 0xFF41
    case SCY  = 0xFF42
    case SCX  = 0xFF43
    case LY   = 0xFF44
    case LYC  = 0xFF45
    case DMA  = 0xFF46
    case BGP  = 0xFF47
    case OBP0 = 0xFF48
    case OBP1 = 0xFF49
    case WY   = 0xFF4A
    case WX   = 0xFF4B
  }

  // MARK: .searchingOAM state

  /** How many cycles have been advanced for the current lcdMode. */
  private var lcdModeCycle: Int = 0

  // MARK: .transferringToLCDDriver state
  private struct Pixel {
    let color: UInt8
    let palette: UInt8
    let spritePriority: UInt8
    let bgPriority: UInt8
  }
  private var bgfifo: [Pixel] = []
  private var spritefifo: [Pixel] = []
  private var transferringToLCDDriverCycle: Int = 0
  private var scanlineX: UInt8 = 0
  private var scanlineScrollX: UInt8 = 0
  private var windowYPlot: UInt8 = 0
  private var bgYPlot: UInt8 = 0
  private var lastBackgroundPixel: UInt8 = 0
  private var lastStatSignal = false

  /**
   Incremented every time a new vblank occurs.

   Primarily used by the emulator to observe whether a new vblank has occurred and to extract the vram data if so.
   */
  public private(set) var vblankCounter: Int = 0
}

// MARK: - Emulation

extension LCDController {
  static let searchingOAMLength = 20
  static let scanlineCycleLength = 114

  private func plot(x: UInt8, y: UInt8, byte: UInt8, palette: Palette) {
    let color = palette[Int(bitPattern: UInt(truncatingIfNeeded: byte))]
    registers.screenData[Int(bitPattern: UInt(truncatingIfNeeded: LCDController.screenSize.width) * UInt(truncatingIfNeeded: y) + UInt(truncatingIfNeeded: x))] = color
  }

  private func backgroundPixel(x: UInt8, y: UInt8, window: Bool) -> UInt8 {
    let wideX = UInt16(truncatingIfNeeded: x)
    let wideY = UInt16(truncatingIfNeeded: y)
    let tileX = Int16(bitPattern: wideX / 8)
    let tileY = Int16(bitPattern: wideY / 8)
    let tileOffsetX = Int16(bitPattern: wideX % 8)
    let tileOffsetY = Int16(bitPattern: wideY % 8)

    let tileIndex: UInt8
    let tileMapIndex = Int(truncatingIfNeeded: tileX &+ tileY &* 32)
    switch window ? registers.windowTileMapAddress : registers.backgroundTileMapAddress {
    case .x9800:
      tileIndex = registers.tileMap[tileMapIndex]
    case .x9C00:
      tileIndex = registers.tileMap[0x400 + tileMapIndex]
    }

    let tileData0: UInt8
    let tileData1: UInt8
    switch registers.tileDataAddress {
    case .x8800:
      let signedTileIndex = Int8(bitPattern: tileIndex)
      let tileDataIndex = 0x1000 + Int(truncatingIfNeeded: (Int16(truncatingIfNeeded: signedTileIndex) &* 16) &+ tileOffsetY &* 2)
      tileData0 = registers.tileData[tileDataIndex]
      tileData1 = registers.tileData[tileDataIndex + 1]
    case .x8000:
      let tileDataIndex = Int(truncatingIfNeeded: Int16(bitPattern: UInt16(truncatingIfNeeded: tileIndex) &* 16) &+ tileOffsetY &* 2)
      tileData0 = registers.tileData[tileDataIndex]
      tileData1 = registers.tileData[tileDataIndex + 1]
    }

    let lsb: UInt8 = (tileData0 & (0x80 >> tileOffsetX)) > 0 ? 0b01 : 0
    let msb: UInt8 = (tileData1 & (0x80 >> tileOffsetX)) > 0 ? 0b10 : 0

    lastBackgroundPixel = msb | lsb
    return lastBackgroundPixel
  }

  private func plot() {
    if registers.windowEnable && (registers.windowX &- 7) <= scanlineX && registers.windowY <= registers.ly {
      plot(x: scanlineX, y: registers.ly,
           byte: backgroundPixel(x: scanlineX &- (registers.windowX &- 7), y: windowYPlot, window: true),
           palette: registers.backgroundPalette)
    } else if registers.backgroundEnable {
      plot(x: scanlineX, y: registers.ly,
           byte: backgroundPixel(x: scanlineX &+ scanlineScrollX, y: bgYPlot, window: false),
           palette: registers.backgroundPalette)
    } else {
      lastBackgroundPixel = 0
    }

    // TODO: Provide the intersected OAMs to the pixel pushing mode on initialization.
    if modeOAMSearch.intersectedOAMs.isEmpty {
      return
    }

    for sprite in modeOAMSearch.intersectedOAMs {
      guard sprite.x > scanlineX && sprite.x <= scanlineX + 8 else {
        continue
      }
      let wideScanlineX = Int16(truncatingIfNeeded: Int8(bitPattern: scanlineX))
      let wideScanlineY = Int16(truncatingIfNeeded: Int8(bitPattern: registers.ly))
      let wideSpriteX = Int16(truncatingIfNeeded: Int8(bitPattern: sprite.x))
      let wideSpriteY = Int16(truncatingIfNeeded: Int8(bitPattern: sprite.y))
      let tileIndex: Int16
      var tileOffsetX = wideScanlineX + 8 - wideSpriteX
      var tileOffsetY = wideScanlineY + 16 - wideSpriteY

      switch registers.spriteSize {
      case .x8x16:
        let wideTile = Int16(truncatingIfNeeded: Int8(bitPattern: sprite.tile))
        if tileOffsetY > 7 && !sprite.yflip {
          tileOffsetY -= 8;
          tileIndex = wideTile | 0x01
        } else if tileOffsetY <= 7 && !sprite.yflip  {
          tileIndex = wideTile & 0xFE
        } else if tileOffsetY > 7 && sprite.yflip {
          tileOffsetY = 15 - tileOffsetY
          tileIndex = wideTile & 0xFE
        } else if tileOffsetY <= 7 && sprite.yflip {
          tileIndex = wideTile | 0x01
          tileOffsetY = 7 - tileOffsetY
        } else {
          tileIndex = 0
        }
      case .x8x8:
        tileIndex = Int16(truncatingIfNeeded: Int8(bitPattern: sprite.tile))
        if sprite.yflip {
          tileOffsetY = 7 - tileOffsetY
        }
      }
      if sprite.xflip {
        tileOffsetX = 7 - tileOffsetX
      }

      let tileData0: UInt8
      let tileData1: UInt8
      let tileDataIndex = Int(truncatingIfNeeded: (tileIndex &* 16) &+ tileOffsetY &* 2)
      tileData0 = registers.tileData[tileDataIndex]
      tileData1 = registers.tileData[tileDataIndex + 1]

      let lsb: UInt8 = (tileData0 & (0x80 >> tileOffsetX)) > 0 ? 0b01 : 0
      let msb: UInt8 = (tileData1 & (0x80 >> tileOffsetX)) > 0 ? 0b10 : 0
      let pixel = msb | lsb
      if pixel > 0 {
        let pixelBehindBg = sprite.priority && lastBackgroundPixel > 0
        if !pixelBehindBg {
          let palette: Palette
          switch sprite.palette {
          case .obj0pal:
            palette = registers.objectPallete0
          case .obj1pal:
            palette = registers.objectPallete1
          }
          plot(x: scanlineX, y: registers.ly, byte: pixel, palette: palette)
        }
        break
      }
    }
  }

  /** Executes a single machine cycle. */
  public func advance(memory: AddressableMemory) {
    //
    // - https://www.reddit.com/r/Gameboy/comments/a1c8h0/what_happens_when_a_gameboy_screen_is_disabled/eap4f8c/?utm_source=reddit&utm_medium=web2x&context=3
    // - https://github.com/trekawek/coffee-gb/blob/088b86fb17109b8cac98e6394108b3561f443d54/src/main/java/eu/rekawek/coffeegb/gpu/Gpu.java#L171-L173
    // - https://github.com/spec-chum/SpecBoy/blob/5d1294d77648897a2a218a7fdcc33fbeb1e79038/SpecBoy/Ppu.cs#L214-L217
    guard registers.lcdDisplayEnable else {
      return
    }

    lcdModeCycle += 1

    // TODO: Evaluate whether line 153 needs to treated as line 0 for lcd STAT purposes.
    // - http://forums.nesdev.com/viewtopic.php?f=20&t=13727
    // - https://github.com/shonumi/gbe-plus/commit/c878372d271439e093ce0347fc92a39050090680
    // - https://github.com/spec-chum/SpecBoy/blob/master/SpecBoy/Ppu.cs
    // - https://github.com/LIJI32/SameBoy/blob/29a3b18186c181399f4b99b9111ca9d8b5726886/Core/display.c#L1357-L1378
    // - https://github.com/trekawek/coffee-gb/blob/088b86fb17109b8cac98e6394108b3561f443d54/src/main/java/eu/rekawek/coffeegb/gpu/Gpu.java#L178-L182

    switch registers.lcdMode {
    case .searchingOAM:
      if let nextMode = modeOAMSearch.advance(memory: memory) {
        changeMode(to: nextMode)
        lcdModeCycle = 20
      }

    case .transferringToLCDDriver:
      transferringToLCDDriverCycle += 1

      if transferringToLCDDriverCycle > 1 && scanlineX < 160 {
        plot()
        scanlineX += 1
        plot()
        scanlineX += 1
        plot()
        scanlineX += 1
        plot()
        scanlineX += 1
      }

      if lcdModeCycle >= LCDController.searchingOAMLength + 43 {
        precondition(scanlineX >= 160)
        changeMode(to: .hblank)
        // Don't reset lcdModeCycle yet, as this mode can actually end early.

        registers.requestHBlankInterruptIfNeeded(memory: memory)
      }

    case .hblank:
      if let nextMode = modeHBlank.advance(memory: memory) {
        // TODO: Once all modes are handled by classes this switch statement can be removed and this handled generally.
        if nextMode == .vblank {
          vblankCounter += 1
        }
        changeMode(to: nextMode)
      }

    case .vblank:
      if let nextMode = modeVBlank.advance(memory: memory) {
        changeMode(to: nextMode)
      }
    }
  }

  private func changeMode(to mode: LCDCMode) {
    switch mode {
    case .searchingOAM: modeOAMSearch.start()
    case .vblank:       modeVBlank.start()

    case .transferringToLCDDriver:
      windowYPlot = registers.ly &- registers.windowY
      bgYPlot = registers.ly &+ registers.scrollY
      transferringToLCDDriverCycle = 0
      scanlineX = 0
      scanlineScrollX = registers.scrollX

    case .hblank:
      break
    }

    registers.lcdMode = mode
  }
}

// MARK: - AddressableMemory

extension LCDController: AddressableMemory {
  public func read(from address: LR35902.Address) -> UInt8 {
    if LCDController.tileMapRegion.contains(address) {
      if isVramAccessible() {
        return registers.tileMap[Int(address - LCDController.tileMapRegion.lowerBound)]
      } else {
        return 0xFF
      }
    }
    if LCDController.tileDataRegion.contains(address) {
      if isVramAccessible() {
        return registers.tileData[Int(address - LCDController.tileDataRegion.lowerBound)]
      } else {
        return 0xFF
      }
    }
    if OAM.addressableRange.contains(address) {
      guard registers.lcdMode == .hblank || registers.lcdMode == .vblank else {
        return 0xFF  // OAM are only accessible during hblank and vblank
      }
      return oam.read(from: address)
    }

    guard let lcdAddress = Addresses(rawValue: address) else {
      preconditionFailure("Invalid address")
    }

    if registers.lcdMode == .transferringToLCDDriver {
      switch lcdAddress {
      case .BGP, .OBP0, .OBP1:
        return 0xFF // Palettes are not readable during pixel transfer
      default:
        break // Fall-through
      }
    }

    switch lcdAddress {
    case .LCDC: return registers.lcdc

    case .LY:   return registers.ly
    case .LYC:  return registers.lyc

    case .SCY:  return registers.scrollY
    case .SCX:  return registers.scrollX

    case .WY:   return registers.windowY
    case .WX:   return registers.windowX

    case .BGP:  return registers.bitsForPalette(registers.backgroundPalette)
    case .OBP0: return registers.bitsForPalette(registers.objectPallete0)
    case .OBP1: return registers.bitsForPalette(registers.objectPallete1)

    case .STAT: return registers.stat

    default:
      fatalError()
    }
  }

  private func isVramAccessible() -> Bool {
    // "When the LCD display is off you can write to video memory at any time with out restrictions. While it is on you
    // can only write to video memory during H-Blank and V-Blank."
    // - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
    // - https://github.com/spec-chum/SpecBoy/blob/master/SpecBoy/Ppu.cs#L132-L142
    // Note that coffee-gb appears to have disabled any of these checks and always allows VRAM access.
    // - https://github.com/trekawek/coffee-gb/blob/088b86fb17109b8cac98e6394108b3561f443d54/src/main/java/eu/rekawek/coffeegb/gpu/Gpu.java#L94
    // Sameboy allows read/write to be selectively enabled/disabled depending on hardware.
    // - https://github.com/LIJI32/SameBoy/blob/29a3b18186c181399f4b99b9111ca9d8b5726886/Core/display.c#L992-L993
    return !registers.lcdDisplayEnable || registers.lcdMode != .transferringToLCDDriver
  }

  public func write(_ byte: UInt8, to address: LR35902.Address) {
    if LCDController.tileMapRegion.contains(address) {
      if isVramAccessible() {
        registers.tileMap[Int(address - LCDController.tileMapRegion.lowerBound)] = byte
      }
      return
    }
    if LCDController.tileDataRegion.contains(address) {
      if isVramAccessible() {
        registers.tileData[Int(address - LCDController.tileDataRegion.lowerBound)] = byte
      }
      return
    }
    if OAM.addressableRange.contains(address) {
      guard registers.lcdMode == .hblank || registers.lcdMode == .vblank else {
        // OAM are only accessible during hblank and vblank.
        // Note that DMAController has direct write access and circumvents this check when running.
        return
      }
      oam.write(byte, to: address)
      return
    }
    guard let lcdAddress = Addresses(rawValue: address) else {
      preconditionFailure("Invalid address")
    }

    if registers.lcdMode == .transferringToLCDDriver {
      switch lcdAddress {
      case .BGP, .OBP0, .OBP1:
        return // Palettes are not writable during pixel transfer
      default:
        break // Fall-through
      }
    }

    switch lcdAddress {
    case .LCDC:
      let wasLCDDisplayEnabled = registers.lcdDisplayEnable

      registers.lcdc = byte

      // When lcdDisplayEnable transfers from on to off:
      // - ly is reset to zero.
      // - LCD clock is reset to zero.
      // - Enters mode 0 (OAM search)
      // - https://www.reddit.com/r/Gameboy/comments/a1c8h0/what_happens_when_a_gameboy_screen_is_disabled/eap4f8c/?utm_source=reddit&utm_medium=web2x&context=3
      //
      if wasLCDDisplayEnabled && !registers.lcdDisplayEnable {
        registers.ly = 0
        changeMode(to: .searchingOAM)
      }
      // TODO: Do we need to do anything when the LCD is enabled again? There is mention that the first frame after
      // turning the LCD back on should be ignored.
      // - https://github.com/spec-chum/SpecBoy/blob/5d1294d77648897a2a218a7fdcc33fbeb1e79038/SpecBoy/Ppu.cs#L95-L100
      // - https://github.com/trekawek/coffee-gb/blob/088b86fb17109b8cac98e6394108b3561f443d54/src/main/java/eu/rekawek/coffeegb/gpu/Gpu.java#L275-L277
      // - https://www.reddit.com/r/EmuDev/comments/6exyxu/does_the_game_boy_skip_the_first_frame_after/dieiau8/

    case .LY:
      // "Any writes to LY while the LCD is enabled are ignored. That bit of info is from Pan Docs, which is incorrect."
      // - https://forums.nesdev.com/viewtopic.php?t=16434#p203762
      // "When the LCD is off this register is fixed at 00h."
      // - https://github.com/AntonioND/giibiiadvance/blob/master/docs/TCAGBD.pdf
      // With the above in mind, we simply ignore writes to this register. Note that this contradicts the Pan Docs which
      // states that "Writing will reset the counter."
      // - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
      break

    case .LYC:  registers.lyc = byte
      // TODO: Do we need to fire a coincidence check here?
      // - https://github.com/spec-chum/SpecBoy/blob/5d1294d77648897a2a218a7fdcc33fbeb1e79038/SpecBoy/Ppu.cs#L126

    case .SCY:  registers.scrollY = byte
    case .SCX:  registers.scrollX = byte

    case .WY:   registers.windowY = byte
    case .WX:   registers.windowX = byte

    case .BGP:  registers.backgroundPalette = registers.paletteFromBits(byte)
    case .OBP0: registers.objectPallete0 = registers.paletteFromBits(byte)
    case .OBP1: registers.objectPallete1 = registers.paletteFromBits(byte)

    case .STAT: registers.stat = byte

    default:
      fatalError()
    }
  }

  public func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return .memory(address)
  }
}
