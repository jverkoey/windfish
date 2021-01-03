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
  }

  let oam: OAM

  var tileMap = UnsafeMutableRawBufferPointer.allocate(byteCount: tileMapRegion.count, alignment: 1)
  var tileData = UnsafeMutableRawBufferPointer.allocate(byteCount:  tileDataRegion.count, alignment: 1)

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

  enum LCDCMode {
    case hblank
    case vblank

    // TODO: Not able to read oamram during this mode
    case searchingOAM

    // TODO: Any reads of vram or oamram during this mode should return 0xff; writes are ignored
    case transferringToLCDDriver

    var bits: UInt8 {
      switch self {
      case .hblank:                   return 0b0000_0000
      case .vblank:                   return 0b0000_0001
      case .searchingOAM:             return 0b0000_0010
      case .transferringToLCDDriver:  return 0b0000_0011
      }
    }
  }
  var enableCoincidenceInterrupt = false          // bit 6
  var enableOAMInterrupt = false                  // bit 5
  var enableVBlankInterrupt = false               // bit 4
  var enableHBlankInterrupt = false               // bit 3
  var coincidence: Bool {                         // bit 2
    return scanlineY == lyc
  }
  private var lcdMode = LCDCMode.searchingOAM {   // bits 1 and 0
    didSet {
      if lcdMode == .searchingOAM {
        intersectedOAMs = []
        oamIndex = 0
      } else if lcdMode == .transferringToLCDDriver {
        windowYPlot = scanlineY &- windowY
        bgYPlot = scanlineY &+ scrollY
        transferringToLCDDriverCycle = 0
        scanlineX = 0
      }
    }
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
  private var windowYPlot: UInt8 = 0
  private var bgYPlot: UInt8 = 0
  private var lastBackgroundPixel: UInt8 = 0

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
    let color = palette[Int(byte)]
    screenData[LCDController.screenSize.width * Int(y) + Int(x)] = color
  }

  private func backgroundPixel(x: UInt8, y: UInt8, window: Bool) -> UInt8 {
    let wideX = UInt16(truncatingIfNeeded: x)
    let wideY = UInt16(truncatingIfNeeded: y)
    let tileX = Int16(bitPattern: wideX / 8)
    let tileY = Int16(bitPattern: wideY / 8)
    let tileOffsetX = Int16(bitPattern: wideX % 8)
    let tileOffsetY = Int16(bitPattern: wideY % 8)

    let tileIndex: UInt8
    let tileMapIndex = Int(tileX + tileY &* 32)
    switch window ? windowTileMapAddress : backgroundTileMapAddress {
    case .x9800:
      tileIndex = tileMap[tileMapIndex]
    case .x9C00:
      tileIndex = tileMap[0x400 + tileMapIndex]
    }

    let tileData0: UInt8
    let tileData1: UInt8
    switch tileDataAddress {
    case .x8000:
      let tileDataIndex = Int(truncatingIfNeeded: Int16(bitPattern: UInt16(truncatingIfNeeded: tileIndex) &* 16) &+ tileOffsetY &* 2)
      tileData0 = tileData[tileDataIndex]
      tileData1 = tileData[tileDataIndex + 1]
    case .x8800:
      let tileDataIndex = Int(truncatingIfNeeded: 0x1000 + Int16(truncatingIfNeeded: Int8(bitPattern: tileIndex)) &* 16 &+ tileOffsetY &* 2)
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
           byte: backgroundPixel(x: scanlineX &+ scrollX, y: bgYPlot, window: false),
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
      let tileIndex: Int16
      var tileOffsetX = Int16(truncatingIfNeeded: scanlineX) + 8 - Int16(bitPattern: UInt16(truncatingIfNeeded: sprite.x))
      var tileOffsetY = Int16(truncatingIfNeeded: scanlineY) + 16 - Int16(bitPattern: UInt16(truncatingIfNeeded: sprite.y))

      switch spriteSize {
      case .x8x16:
        let flipY = sprite.flags & 0b0100_0000 > 0
        let wideTile = Int16(bitPattern: UInt16(truncatingIfNeeded: sprite.tile))
        if tileOffsetY > 7 && !flipY {
          tileOffsetY -= 8;
          tileIndex = wideTile | 0x01
        } else if tileOffsetY <= 7 && !flipY  {
          tileIndex = wideTile & 0xFE
        } else if tileOffsetY > 7 && flipY {
          tileOffsetY = 15 - tileOffsetY
          tileIndex = wideTile & 0xFE
        } else if tileOffsetY <= 7 && flipY {
          tileIndex = wideTile | 0x01
          tileOffsetY = 7 - tileOffsetY
        } else {
          tileIndex = 0
        }
      case .x8x8:
        tileIndex = Int16(bitPattern: UInt16(truncatingIfNeeded: sprite.tile))
        if sprite.flags & 0b0100_0000 > 0 {
          tileOffsetY = 7 - tileOffsetY
        }
      }
      if sprite.flags & 0b0010_0000 > 0 {
        tileOffsetX = 7 - tileOffsetX
      }

      let tileData0: UInt8
      let tileData1: UInt8
      let tileDataIndex = Int(truncatingIfNeeded: Int16(bitPattern: UInt16(truncatingIfNeeded: tileIndex) &* 16) &+ tileOffsetY &* 2)
      tileData0 = tileData[tileDataIndex]
      tileData1 = tileData[tileDataIndex + 1]

      let lsb: UInt8 = (tileData0 & (0x80 >> tileOffsetX)) > 0 ? 0b01 : 0
      let msb: UInt8 = (tileData1 & (0x80 >> tileOffsetX)) > 0 ? 0b10 : 0
      let pixel = msb | lsb
      if pixel > 0 {
        let pixelBehindBg = sprite.flags & 0b1000_0000 > 0 && lastBackgroundPixel > 0
        if !pixelBehindBg {
          let palette: Palette
          if sprite.flags & 0b0001_0000 > 0 {
            palette = objectPallete0
          } else {
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

    switch lcdMode {
    case .searchingOAM:
      // One OAM search takes two T-cycles, so we can perform two per machine cycle.
      searchNextOAM()
      searchNextOAM()

      if lcdModeCycle >= LCDController.searchingOAMLength {
//        precondition(intersectedOAMs.count == 0, "Sprites not handled yet.")
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

      if lcdModeCycle >= 63 {
        lcdMode = .hblank
        // Don't reset lcdModeCycle yet, as this mode can actually end early.
      }
      break
    case .hblank:
      if lcdModeCycle >= LCDController.scanlineCycleLength {
        scanlineY += 1
        if scanlineY < 144 {
          lcdMode = .searchingOAM
          lcdModeCycle = 0
        } else {
          // No more lines to draw.
          lcdMode = .vblank

          vblankCounter += 1

          var interruptFlag = LR35902.Instruction.Interrupt(rawValue: memory.read(from: LR35902.interruptFlagAddress))
          interruptFlag.insert(.vBlank)
          memory.write(interruptFlag.rawValue, to: LR35902.interruptFlagAddress)
        }
      }
      break
    case .vblank:
      if lcdModeCycle % LCDController.scanlineCycleLength == 0 {
        scanlineY += 1

        if scanlineY >= 154 {
          scanlineY = 0
          lcdMode = .searchingOAM
        }
      }
      break
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
      return tileMap[Int(address - LCDController.tileMapRegion.lowerBound)]
    }
    if LCDController.tileDataRegion.contains(address) {
      return tileData[Int(address - LCDController.tileDataRegion.lowerBound)]
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
      tileMap[Int(address - LCDController.tileMapRegion.lowerBound)] = byte
      return
    }
    if LCDController.tileDataRegion.contains(address) {
      tileData[Int(address - LCDController.tileDataRegion.lowerBound)] = byte
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

    case .LY:  scanlineY = 0
    case .LYC: lyc = 0

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
