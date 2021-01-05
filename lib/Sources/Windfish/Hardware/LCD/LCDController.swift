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

  deinit {
    tileMap.deallocate()
    tileData.deallocate()
    screenData.deallocate()
  }

  init(oam: OAM) {
    self.oam = oam
    tileMap.initializeMemory(as: UInt8.self, repeating: 0)
    tileData.initializeMemory(as: UInt8.self, repeating: 0)
    screenData.initializeMemory(as: UInt8.self, repeating: 0)
  }

  let oam: OAM

  var tileMap = UnsafeMutableRawBufferPointer.allocate(byteCount: tileMapRegion.count, alignment: 1)
  var tileData = UnsafeMutableRawBufferPointer.allocate(byteCount: tileDataRegion.count, alignment: 1)

  var bufferToggle = false
  public static let screenSize = (width: 160, height: 144)
  var screenData = UnsafeMutableRawBufferPointer.allocate(byteCount: LCDController.screenSize.width * LCDController.screenSize.height, alignment: 1)

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

  // MARK: LCDC bits (0xFF40)

  enum TileMapAddress {
    case x9800 // 0
    case x9C00 // 1
  }
  enum TileDataAddress {
    case x8800 // 0
    case x8000 // 1
  }
  enum SpriteSize {
    case x8x8  // 0
    case x8x16 // 1

    func height() -> UInt8 {
      switch self {
      case .x8x8:  return 8
      case .x8x16: return 16
      }
    }
  }
  /**
   Whether the display is turned on or not.

   Can only be disabled during V-blank.
   */
  var lcdDisplayEnable = true {                       // bit 7
    willSet {
      precondition(
        (lcdDisplayEnable && !newValue) && scanlineY >= 144  // Can only change during v-blank
          || lcdDisplayEnable == newValue             // No change
          || !lcdDisplayEnable && newValue            // Can always enable.
      )
    }
    didSet {
      if !lcdDisplayEnable {
        scanlineY = 0
        lcdMode = .searchingOAM
      }
    }
  }
  var windowTileMapAddress = TileMapAddress.x9800      // bit 6
  var windowEnable = false                             // bit 5
  var tileDataAddress = TileDataAddress.x8000          // bit 4
  var backgroundTileMapAddress = TileMapAddress.x9800  // bit 3
  var spriteSize = SpriteSize.x8x8                     // bit 2
  var objEnable = false                                // bit 1
  var backgroundEnable = true                          // bit 0

  // MARK: STAT bits (0xFF41)
                                                  // 76543210
  var enableCoincidenceInterrupt = false          //  x
  var enableOAMInterrupt = false                  //   x
  var enableVBlankInterrupt = false               //    x
  var enableHBlankInterrupt = false               //     x
  var coincidence: Bool {                         //      x
    return scanlineY == lyc                       // 76543210
  }
  private var lcdMode = LCDCMode.searchingOAM {   //       xx
    didSet {
      if lcdMode == .searchingOAM {
        intersectedOAMs = []
        oamIndex = 0
        lcdModeCycle = 0
      } else if lcdMode == .vblank {
        lcdModeCycle = 0
      } else if lcdMode == .transferringToLCDDriver {
        windowYPlot = scanlineY &- windowY
        bgYPlot = scanlineY &+ scrollY
        transferringToLCDDriverCycle = 0
        scanlineX = 0
        scanlineScrollX = scrollX
      }
    }
  }
  enum LCDCMode {
    var bits: UInt8 {
      switch self {
      case .hblank:                   return 0b0000_0000
      case .vblank:                   return 0b0000_0001
      case .searchingOAM:             return 0b0000_0010
      case .transferringToLCDDriver:  return 0b0000_0011
      }
    }

    case hblank                   // Mode 0
    case vblank                   // Mode 1

    // TODO: Not able to read oamram during this mode
    case searchingOAM             // Mode 2

    // TODO: Any reads of vram or oamram during this mode should return 0xff; writes are ignored
    case transferringToLCDDriver  // Mode 3
  }

  // MARK: SY and XX (0xFF42 and 0xFF43)

  var scrollY: UInt8 = 0
  var scrollX: UInt8 = 0

  // MARK: LY (0xFF44)

  /** The vertical line to which data is transferred to the display. */
  var scanlineY: UInt8 = 0

  // MARK: LYC (0xFF45)

  var lyc: UInt8 = 0

  // MARK: BGP (0xFF47)

  typealias Palette = [UInt8]

  private func bitsForPalette(_ palette: Palette) -> UInt8 {
    return (palette[0] & UInt8(0b0000_0011))
        | ((palette[1] & UInt8(0b0000_0011)) << 2)
        | ((palette[2] & UInt8(0b0000_0011)) << 4)
        | ((palette[3] & UInt8(0b0000_0011)) << 6)
  }

  private func paletteFromBits(_ bits: UInt8) -> Palette {
    return [
      bits & 0b0000_0011,
      (bits >> 2) & 0b0000_0011,
      (bits >> 4) & 0b0000_0011,
      (bits >> 6) & 0b0000_0011,
    ]
  }

  /** Shade values for background and window tiles. */
  var backgroundPalette: Palette = [
    0,
    1,
    2,
    3,
  ]

  // MARK: OBP0 and OBP1 (0xFF48 and 0xFF49)

  /** Shade values for background and window tiles. */
  var objectPallete0: Palette = [
    0,
    1,
    2,
    3,
  ]

  /** Shade values for background and window tiles. */
  var objectPallete1: Palette = [
    0,
    1,
    2,
    3,
  ]

  // MARK: WY and WX (0xFF4A and 0xFF4B)

  var windowY: UInt8 = 0
  var windowX: UInt8 = 0

  // MARK: .searchingOAM state

  /** How many cycles have been advanced for the current lcdMode. */
  private var lcdModeCycle: Int = 0
  private var intersectedOAMs: [OAM.Sprite] = []
  private var oamIndex = 0

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
    screenData[Int(bitPattern: UInt(truncatingIfNeeded: LCDController.screenSize.width) * UInt(truncatingIfNeeded: y) + UInt(truncatingIfNeeded: x))] = color
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
    switch window ? windowTileMapAddress : backgroundTileMapAddress {
    case .x9800:
      tileIndex = tileMap[tileMapIndex]
    case .x9C00:
      tileIndex = tileMap[0x400 + tileMapIndex]
    }

    let tileData0: UInt8
    let tileData1: UInt8
    switch tileDataAddress {
    case .x8800:
      let signedTileIndex = Int8(bitPattern: tileIndex)
      let tileDataIndex = 0x1000 + Int(truncatingIfNeeded: (Int16(truncatingIfNeeded: signedTileIndex) &* 16) &+ tileOffsetY &* 2)
      tileData0 = tileData[tileDataIndex]
      tileData1 = tileData[tileDataIndex + 1]
    case .x8000:
      let tileDataIndex = Int(truncatingIfNeeded: Int16(bitPattern: UInt16(truncatingIfNeeded: tileIndex) &* 16) &+ tileOffsetY &* 2)
      tileData0 = tileData[tileDataIndex]
      tileData1 = tileData[tileDataIndex + 1]
    }

    let lsb: UInt8 = (tileData0 & (0x80 >> tileOffsetX)) > 0 ? 0b01 : 0
    let msb: UInt8 = (tileData1 & (0x80 >> tileOffsetX)) > 0 ? 0b10 : 0

    lastBackgroundPixel = msb | lsb
    return lastBackgroundPixel
  }

  private func plot() {
    if windowEnable && (windowX &- 7) <= scanlineX && windowY <= scanlineY {
      plot(x: scanlineX, y: scanlineY,
           byte: backgroundPixel(x: scanlineX &- (windowX &- 7), y: windowYPlot, window: true),
           palette: backgroundPalette)
    } else if backgroundEnable {
      plot(x: scanlineX, y: scanlineY,
           byte: backgroundPixel(x: scanlineX &+ scanlineScrollX, y: bgYPlot, window: false),
           palette: backgroundPalette)
    } else {
      lastBackgroundPixel = 0
    }

    if intersectedOAMs.isEmpty {
      return
    }

    for sprite in intersectedOAMs {
      guard sprite.x > scanlineX && sprite.x <= scanlineX + 8 else {
        continue
      }
      let wideScanlineX = Int16(truncatingIfNeeded: Int8(bitPattern: scanlineX))
      let wideScanlineY = Int16(truncatingIfNeeded: Int8(bitPattern: scanlineY))
      let wideSpriteX = Int16(truncatingIfNeeded: Int8(bitPattern: sprite.x))
      let wideSpriteY = Int16(truncatingIfNeeded: Int8(bitPattern: sprite.y))
      let tileIndex: Int16
      var tileOffsetX = wideScanlineX + 8 - wideSpriteX
      var tileOffsetY = wideScanlineY + 16 - wideSpriteY

      switch spriteSize {
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
      tileData0 = tileData[tileDataIndex]
      tileData1 = tileData[tileDataIndex + 1]

      let lsb: UInt8 = (tileData0 & (0x80 >> tileOffsetX)) > 0 ? 0b01 : 0
      let msb: UInt8 = (tileData1 & (0x80 >> tileOffsetX)) > 0 ? 0b10 : 0
      let pixel = msb | lsb
      if pixel > 0 {
        let pixelBehindBg = sprite.priority && lastBackgroundPixel > 0
        if !pixelBehindBg {
          let palette: Palette
          switch sprite.palette {
          case .obj0pal:
            palette = objectPallete0
          case .obj1pal:
            palette = objectPallete1
          }
          plot(x: scanlineX, y: scanlineY, byte: pixel, palette: palette)
        }
        break
      }
    }
  }

  /** Executes a single machine cycle.  */
  public func advance(memory: AddressableMemory) {
    guard lcdDisplayEnable else {
      return
    }

    lcdModeCycle += 1

    // TODO: Evaluate whether line 153 needs to treated as line 0 for lcd STAT purposes.
    // - http://forums.nesdev.com/viewtopic.php?f=20&t=13727
    // - https://github.com/shonumi/gbe-plus/commit/c878372d271439e093ce0347fc92a39050090680
    // - https://github.com/spec-chum/SpecBoy/blob/master/SpecBoy/Ppu.cs
    // - https://github.com/LIJI32/SameBoy/blob/29a3b18186c181399f4b99b9111ca9d8b5726886/Core/display.c#L1357-L1378
    // - https://github.com/trekawek/coffee-gb/blob/088b86fb17109b8cac98e6394108b3561f443d54/src/main/java/eu/rekawek/coffeegb/gpu/Gpu.java#L178-L182

    switch lcdMode {
    case .searchingOAM:
      // One OAM search takes two T-cycles, so we can perform two per machine cycle.
      searchNextOAM()
      searchNextOAM()

      if lcdModeCycle >= LCDController.searchingOAMLength {
        lcdMode = .transferringToLCDDriver
        bgfifo.removeAll()
        spritefifo.removeAll()
      }
      break
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
        lcdMode = .hblank
        // Don't reset lcdModeCycle yet, as this mode can actually end early.

        requestHBlankInterruptIfNeeded(memory: memory)
      }
      break
    case .hblank:
      if lcdModeCycle >= LCDController.scanlineCycleLength {
        scanlineY += 1
        if scanlineY < 144 {
          lcdMode = .searchingOAM
        } else {
          // No more lines to draw.
          lcdMode = .vblank

          vblankCounter += 1

          var interruptFlag = LR35902.Interrupt(rawValue: memory.read(from: LR35902.interruptFlagAddress))
          interruptFlag.insert(.vBlank)
          memory.write(interruptFlag.rawValue, to: LR35902.interruptFlagAddress)

          requestVBlankInterruptIfNeeded(memory: memory)
        }

        requestOAMInterruptIfNeeded(memory: memory)
        requestCoincidenceInterruptIfNeeded(memory: memory)
      }
      break
    case .vblank:
      if lcdModeCycle >= LCDController.scanlineCycleLength {
        scanlineY += 1
        lcdModeCycle = 0

        if scanlineY >= 154 {
          scanlineY = 0
          lcdMode = .searchingOAM
          requestOAMInterruptIfNeeded(memory: memory)
        }

        requestCoincidenceInterruptIfNeeded(memory: memory)
      }
      break
    }
  }

  private func raiseLCDStatInterrupt(memory: AddressableMemory) {
    var interruptFlag = LR35902.Interrupt(rawValue: memory.read(from: LR35902.interruptFlagAddress))
    interruptFlag.insert(.lcdStat)
    memory.write(interruptFlag.rawValue, to: LR35902.interruptFlagAddress)
  }

  private func requestOAMInterruptIfNeeded(memory: AddressableMemory) {
    if enableOAMInterrupt {
      raiseLCDStatInterrupt(memory: memory)
    }
  }

  private func requestHBlankInterruptIfNeeded(memory: AddressableMemory) {
    if enableHBlankInterrupt {
      raiseLCDStatInterrupt(memory: memory)
    }
  }

  private func requestVBlankInterruptIfNeeded(memory: AddressableMemory) {
    if enableVBlankInterrupt {
      raiseLCDStatInterrupt(memory: memory)
    }
  }

  private func requestCoincidenceInterruptIfNeeded(memory: AddressableMemory) {
    if coincidence && enableCoincidenceInterrupt {
      raiseLCDStatInterrupt(memory: memory)
    }
  }

  // MARK: OAM search

  private func searchNextOAM() {
    guard intersectedOAMs.count < 10 else {
      return
    }
    let sprite = oam.sprites[oamIndex]
    oamIndex += 1
    if sprite.x > 0
        && scanlineY + 16 >= sprite.y
        && scanlineY + 16 < sprite.y + spriteSize.height() {
      intersectedOAMs.append(sprite)
    }
  }
}

// MARK: - AddressableMemory

extension LCDController: AddressableMemory {
  public func read(from address: LR35902.Address) -> UInt8 {
    if LCDController.tileMapRegion.contains(address) {
      if lcdMode != .transferringToLCDDriver {
        return tileMap[Int(address - LCDController.tileMapRegion.lowerBound)]
      } else {
        return 0xFF
      }
    }
    if LCDController.tileDataRegion.contains(address) {
      if lcdMode != .transferringToLCDDriver {
        return tileData[Int(address - LCDController.tileDataRegion.lowerBound)]
      } else {
        return 0xFF
      }
    }
    if OAM.addressableRange.contains(address) {
      guard lcdMode == .hblank || lcdMode == .vblank else {
        return 0xFF  // OAM are only accessible during hblank and vblank
      }
      return oam.read(from: address)
    }

    guard let lcdAddress = Addresses(rawValue: address) else {
      preconditionFailure("Invalid address")
    }

    if lcdMode == .transferringToLCDDriver {
      switch lcdAddress {
      case .BGP, .OBP0, .OBP1:
        return 0xFF // Palettes are not readable during pixel transfer
      default:
        break // Fall-through
      }
    }

    switch lcdAddress {
    case .LCDC:
      return (
        (lcdDisplayEnable                       ? 0b1000_0000 : 0)
          | (windowTileMapAddress == .x9C00     ? 0b0100_0000 : 0)
          | (windowEnable                       ? 0b0010_0000 : 0)
          | (tileDataAddress == .x8000          ? 0b0001_0000 : 0)
          | (backgroundTileMapAddress == .x9C00 ? 0b0000_1000 : 0)
          | (spriteSize == .x8x16               ? 0b0000_0100 : 0)
          | (objEnable                          ? 0b0000_0010 : 0)
          | (backgroundEnable                   ? 0b0000_0001 : 0)
      )

    case .LY:   return scanlineY
    case .LYC:  return lyc

    case .SCY:  return scrollY
    case .SCX:  return scrollX

    case .WY:   return windowY
    case .WX:   return windowX

    case .BGP:  return bitsForPalette(backgroundPalette)
    case .OBP0: return bitsForPalette(objectPallete0)
    case .OBP1: return bitsForPalette(objectPallete1)

    case .STAT:
      return (
        (enableCoincidenceInterrupt   ? 0b0100_0000 : 0)
          | (enableOAMInterrupt       ? 0b0010_0000 : 0)
          | (enableVBlankInterrupt    ? 0b0001_0000 : 0)
          | (enableHBlankInterrupt    ? 0b0000_1000 : 0)
          | (coincidence              ? 0b0000_0100 : 0)
          | lcdMode.bits
      )

    default:
      fatalError()
    }
  }

  public func write(_ byte: UInt8, to address: LR35902.Address) {
    if LCDController.tileMapRegion.contains(address) {
      if lcdMode != .transferringToLCDDriver {
        tileMap[Int(address - LCDController.tileMapRegion.lowerBound)] = byte
      }
      return
    }
    if LCDController.tileDataRegion.contains(address) {
      if lcdMode != .transferringToLCDDriver {
        tileData[Int(address - LCDController.tileDataRegion.lowerBound)] = byte
      }
      return
    }
    if OAM.addressableRange.contains(address) {
      guard lcdMode == .hblank || lcdMode == .vblank else {
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

    if lcdMode == .transferringToLCDDriver {
      switch lcdAddress {
      case .BGP, .OBP0, .OBP1:
        return // Palettes are not writable during pixel transfer
      default:
        break // Fall-through
      }
    }

    switch lcdAddress {
    case .LCDC:
      lcdDisplayEnable          = (byte & 0b1000_0000) > 0
      windowTileMapAddress      = (byte & 0b0100_0000) > 0 ? .x9C00 : .x9800
      windowEnable              = (byte & 0b0010_0000) > 0
      tileDataAddress           = (byte & 0b0001_0000) > 0 ? .x8000 : .x8800
      backgroundTileMapAddress  = (byte & 0b0000_1000) > 0 ? .x9C00 : .x9800
      spriteSize                = (byte & 0b0000_0100) > 0 ? .x8x16 : .x8x8
      objEnable                 = (byte & 0b0000_0010) > 0
      backgroundEnable          = (byte & 0b0000_0001) > 0

      if !lcdDisplayEnable {
        scanlineY = 0
        lcdMode = .searchingOAM
      }

    case .LY:   scanlineY = 0
    case .LYC:  lyc = byte

    case .SCY:  scrollY = byte
    case .SCX:  scrollX = byte

    case .WY:   windowY = byte
    case .WX:   windowX = byte

    case .BGP:  backgroundPalette = paletteFromBits(byte)
    case .OBP0: objectPallete0 = paletteFromBits(byte)
    case .OBP1: objectPallete1 = paletteFromBits(byte)

    case .STAT:
      enableCoincidenceInterrupt  = (byte & 0b0100_0000) > 0
      enableOAMInterrupt          = (byte & 0b0010_0000) > 0
      enableVBlankInterrupt       = (byte & 0b0001_0000) > 0
      enableHBlankInterrupt       = (byte & 0b0000_1000) > 0

    default:
      fatalError()
    }
  }

  public func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return .memory(address)
  }
}
