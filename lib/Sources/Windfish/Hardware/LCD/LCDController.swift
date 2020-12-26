import Foundation

// References:
// https://www.youtube.com/watch?v=HyzD8pNlpwI&t=29m19s
// https://gbdev.gg8.se/wiki/articles/Video_Display#FF41_-_STAT_-_LCDC_Status_.28R.2FW.29
// https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf

public struct LCDController {
  public let addressableRanges: [ClosedRange<LR35902.Address>] = [
    0xFF40...0xFF45
  ]

  enum Addresses: LR35902.Address {
    case LCDC = 0xFF40
    case STAT = 0xFF41
    case SCY  = 0xFF42
    case SCX  = 0xFF43
    case LY   = 0xFF44
    case LYC  = 0xFF45
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
  var enableCoincidenceInterrupt = false  // bit 6
  var enableOAMInterrupt = false          // bit 5
  var enableVBlankInterrupt = false       // bit 4
  var enableHBlankInterrupt = false       // bit 3
  var coincidence: Bool {                 // bit 2
    return ly == lyc
  }
  var lcdMode = LCDCMode.hblank           // bits 1 and 0

  // MARK: LY

  /** The vertical line to which data is transferred to the display. */
  var ly: UInt8 = 0

  // MARK: LYC

  var lyc: UInt8 = 0
}

extension LCDController: AddressableMemory {
  public func read(from address: LR35902.Address) -> UInt8 {
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

  public mutating func write(_ byte: UInt8, to address: LR35902.Address) {
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
}
