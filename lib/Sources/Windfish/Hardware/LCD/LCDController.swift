import Foundation

// References:
// - https://www.youtube.com/watch?v=HyzD8pNlpwI&t=29m19s
// - https://gbdev.gg8.se/wiki/articles/Video_Display#FF41_-_STAT_-_LCDC_Status_.28R.2FW.29
// - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
// - http://gameboy.mongenel.com/dmg/asmmemmap.html
// - https://hacktix.github.io/GBEDG/ppu/#the-concept-of-scanlines

public final class LCDController {
  static let oamRegion: ClosedRange<LR35902.Address> = 0xFE00...0xFE9F
  static let tileMapRegion: ClosedRange<LR35902.Address> = 0x9800...0x9FFF
  static let tileDataRegion: ClosedRange<LR35902.Address> = 0x8000...0x97FF
  // 0xFF40...0xFF45

  var tileMap: [LR35902.Address: UInt8] = [:]
  var tileData: [LR35902.Address: UInt8] = [:]

  private struct Sprite {
    var x: UInt8
    var y: UInt8
    var tile: UInt8
    var flags: UInt8
  }
  private var oams: [Sprite] = (0..<40).map { _ -> Sprite in
    Sprite(x: 0, y: 0, tile: 0, flags: 0)
  }

  var bufferToggle = false
  private var screenData: Data {
    get { bufferToggle ? screenData1 : screenData0 }
    set {
      if bufferToggle {
        screenData1 = newValue
      } else {
        screenData0 = newValue
      }
    }
  }
  private var screenData0 = Data(count: 160 * 144)
  private var screenData1 = Data(count: 160 * 144)

  enum Addresses: LR35902.Address {
    case LCDC = 0xFF40
    case STAT = 0xFF41
    case SCY  = 0xFF42
    case SCX  = 0xFF43
    case LY   = 0xFF44
    case LYC  = 0xFF45
    case DMA  = 0xFF46
  }
  var values: [Addresses: UInt8] = [
    .SCY:  0x00,
    .SCX:  0x00,
  ]

  // MARK: LCDC bits

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
        (lcdDisplayEnable && !newValue) && ly >= 144  // Can only change during v-blank
          || lcdDisplayEnable == newValue             // No change
          || !lcdDisplayEnable && newValue            // Can always enable.
      )
    }
    didSet {
      if !lcdDisplayEnable {
        ly = 0
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

  // MARK: STAT bits

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
    return ly == lyc
  }
  private var lcdMode = LCDCMode.searchingOAM {   // bits 1 and 0
    didSet {
      if lcdMode == .searchingOAM {
        intersectedOAMs = []
        oamIndex = 0
      }
    }
  }

  // MARK: LY

  /** The vertical line to which data is transferred to the display. */
  var ly: UInt8 = 0

  // MARK: LYC

  var lyc: UInt8 = 0

  /** How many cycles have been advanced for the current lcdMode. */
  private var lcdModeCycle: Int = 0
  private var intersectedOAMs: [Sprite] = []
  private var oamIndex = 0
}

// MARK: - Emulation

extension LCDController {
  static let scanlineCycleLength = 114

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

      if lcdModeCycle >= 20 {
        precondition(intersectedOAMs.count == 0, "Sprites not handled yet.")
        lcdMode = .transferringToLCDDriver
      }
      break
    case .transferringToLCDDriver:
      // TODO: This isn't always 43.
      if lcdModeCycle >= 63 {
        lcdMode = .hblank
        // Don't reset lcdModeCycle yet, as this mode can actually end early.
      }
      break
    case .hblank:
      if lcdModeCycle >= LCDController.scanlineCycleLength {
        ly += 1
        if ly < 144 {
          lcdMode = .searchingOAM
        } else {
          // No more lines to draw.
          lcdMode = .vblank

          var interruptFlag = LR35902.Instruction.Interrupt(rawValue: memory.read(from: LR35902.interruptFlagAddress))
          interruptFlag.insert(.vBlank)
          memory.write(interruptFlag.rawValue, to: LR35902.interruptFlagAddress)
        }
      }
      break
    case .vblank:
      if lcdModeCycle % LCDController.scanlineCycleLength == 0 {
        ly += 1

        if ly >= 154 {
          ly = 0
          lcdMode = .searchingOAM
        }
      }
      break
    }
  }

  // MARK: OAM search

  private func searchNextOAM() {
    if intersectedOAMs.count < 10 {
      let oam = oams[oamIndex]
      oamIndex += 1
      if oam.x > 0
          && ly + 16 >= oam.y
          && ly + 16 < oam.y + spriteSize.height() {
        intersectedOAMs.append(oam)
      }
    }
  }
}

// MARK: - AddressableMemory

extension LCDController: AddressableMemory {
  public func read(from address: LR35902.Address) -> UInt8 {
    if LCDController.tileMapRegion.contains(address) {
      return tileMap[address]!
    }
    if LCDController.tileDataRegion.contains(address) {
      return tileData[address]!
    }
    if LCDController.oamRegion.contains(address) {
      let relativeOffset = (address - LCDController.oamRegion.lowerBound)
      let oamIndex = relativeOffset / 4
      let oam = oams[Int(oamIndex)]
      switch relativeOffset % 4 {
      case 0: return oam.x
      case 1: return oam.y
      case 2: return oam.tile
      case 3: return oam.flags
      default: fatalError()
      }
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

    case .LY:   return ly
    case .LYC:  return lyc

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
      return values[lcdAddress]!
    }
  }

  public func write(_ byte: UInt8, to address: LR35902.Address) {
    if LCDController.tileMapRegion.contains(address) {
      tileMap[address] = byte
      return
    }
    if LCDController.tileDataRegion.contains(address) {
      tileData[address] = byte
      return
    }
    if LCDController.oamRegion.contains(address) {
      let relativeOffset = (address - LCDController.oamRegion.lowerBound)
      let oamIndex = Int(relativeOffset / 4)
      var oam = oams[oamIndex]
      switch relativeOffset % 4 {
      case 0: oam.x = byte
      case 1: oam.y = byte
      case 2: oam.tile = byte
      case 3: oam.flags = byte
      default: fatalError()
      }
      oams[oamIndex] = oam
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

    case .LY:  ly = 0
    case .LYC: lyc = 0

    case .STAT:
      enableCoincidenceInterrupt  = (byte & 0b0100_0000) > 0
      enableOAMInterrupt          = (byte & 0b0010_0000) > 0
      enableVBlankInterrupt       = (byte & 0b0001_0000) > 0
      enableHBlankInterrupt       = (byte & 0b0000_1000) > 0

    default:
      values[lcdAddress] = byte
    }
  }

  public func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return .memory(address)
  }
}
