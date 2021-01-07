import Foundation

extension PPU {
  final class LCDRegisters {
    deinit {
      tileMap.deallocate()
      tileData.deallocate()
      screenData.deallocate()
    }

    init() {
      tileMap.initializeMemory(as: UInt8.self, repeating: 0)
      tileData.initializeMemory(as: UInt8.self, repeating: 0)
      screenData.initializeMemory(as: UInt8.self, repeating: 0)
    }

    // MARK: VRAM

    var tileMap = UnsafeMutableRawBufferPointer.allocate(byteCount: tileMapRegion.count, alignment: 1)
    var tileData = UnsafeMutableRawBufferPointer.allocate(byteCount: tileDataRegion.count, alignment: 1)
    var screenData = UnsafeMutableRawBufferPointer.allocate(byteCount: PPU.screenSize.width * PPU.screenSize.height, alignment: 1)

    // MARK: LCDC bits (0xFF40)

    var lcdc: UInt8 {
      get {
        return (lcdDisplayEnable                ? 0b1000_0000 : 0)
          | (windowTileMapAddress == .x9C00     ? 0b0100_0000 : 0)
          | (windowEnable                       ? 0b0010_0000 : 0)
          | (tileDataAddress == .x8000          ? 0b0001_0000 : 0)
          | (backgroundTileMapAddress == .x9C00 ? 0b0000_1000 : 0)
          | (spriteSize == .x8x16               ? 0b0000_0100 : 0)
          | (objEnable                          ? 0b0000_0010 : 0)
          | (backgroundEnable                   ? 0b0000_0001 : 0)
      }
      set {
        lcdDisplayEnable          = (newValue & 0b1000_0000) > 0
        windowTileMapAddress      = (newValue & 0b0100_0000) > 0 ? .x9C00 : .x9800
        windowEnable              = (newValue & 0b0010_0000) > 0
        tileDataAddress           = (newValue & 0b0001_0000) > 0 ? .x8000 : .x8800
        backgroundTileMapAddress  = (newValue & 0b0000_1000) > 0 ? .x9C00 : .x9800
        spriteSize                = (newValue & 0b0000_0100) > 0 ? .x8x16 : .x8x8
        objEnable                 = (newValue & 0b0000_0010) > 0
        backgroundEnable          = (newValue & 0b0000_0001) > 0
      }
    }

    /**
     Whether the display is turned on or not.

     Can only be disabled during V-blank.
     */
    var lcdDisplayEnable = true {                       // bit 7
      willSet {
        // "Stopping LCD operation (bit 7 from 1 to 0) must be performed during V-blank to work properly."
        // - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
        precondition(
          (lcdDisplayEnable && !newValue) && lcdMode == .vblank // Can only change during v-blank
            || lcdDisplayEnable == newValue                     // No change
            || !lcdDisplayEnable && newValue                    // Can always enable.
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

    // MARK: STAT bits (0xFF41)
    var stat: UInt8 {
      get {
        return
          (enableCoincidenceInterrupt ? 0b0100_0000 : 0)
          | (enableOAMInterrupt       ? 0b0010_0000 : 0)
          | (enableVBlankInterrupt    ? 0b0001_0000 : 0)
          | (enableHBlankInterrupt    ? 0b0000_1000 : 0)
          | (coincidence              ? 0b0000_0100 : 0)
          | lcdMode.bits
      }
      set {
        enableCoincidenceInterrupt  = (newValue & 0b0100_0000) > 0
        enableOAMInterrupt          = (newValue & 0b0010_0000) > 0
        enableVBlankInterrupt       = (newValue & 0b0001_0000) > 0
        enableHBlankInterrupt       = (newValue & 0b0000_1000) > 0
      }
    }
                                               // 76543210
    var enableCoincidenceInterrupt = false     //  x
    var enableOAMInterrupt = false             //   x
    var enableVBlankInterrupt = false          //    x
    var enableHBlankInterrupt = false          //     x
    var coincidence: Bool = true               //      x
    var lcdMode = LCDCMode.searchingOAM        //       xx
                                               // 76543210

    // MARK: SY and SX (0xFF42 and 0xFF43)

    var scy: UInt8 = 0
    var scx: UInt8 = 0

    // MARK: LY (0xFF44)

    /** The vertical line to which data is transferred to the display. */
    var ly: UInt8 = 0

    // MARK: LYC (0xFF45)

    var lyc: UInt8 = 0

    // MARK: BGP (0xFF47)
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

    // MARK: Raising interrupts

    func raiseLCDStatInterrupt(memory: AddressableMemory) {
      var interruptFlag = LR35902.Interrupt(rawValue: memory.read(from: LR35902.interruptFlagAddress))
      interruptFlag.insert(.lcdStat)
      memory.write(interruptFlag.rawValue, to: LR35902.interruptFlagAddress)
    }

    func requestOAMInterruptIfNeeded(memory: AddressableMemory) {
      if enableOAMInterrupt {
        raiseLCDStatInterrupt(memory: memory)
      }
    }

    func requestHBlankInterruptIfNeeded(memory: AddressableMemory) {
      if enableHBlankInterrupt {
        raiseLCDStatInterrupt(memory: memory)
      }
    }

    func requestVBlankInterruptIfNeeded(memory: AddressableMemory) {
      if enableVBlankInterrupt {
        raiseLCDStatInterrupt(memory: memory)
      }
    }

    // MARK: Data types

    func bitsForPalette(_ palette: Palette) -> UInt8 {
      return(palette[0] & UInt8(0b0000_0011))
        | ((palette[1] & UInt8(0b0000_0011)) << 2)
        | ((palette[2] & UInt8(0b0000_0011)) << 4)
        | ((palette[3] & UInt8(0b0000_0011)) << 6)
    }

    func paletteFromBits(_ bits: UInt8) -> Palette {
      return [
        bits & 0b0000_0011,
        (bits >> 2) & 0b0000_0011,
        (bits >> 4) & 0b0000_0011,
        (bits >> 6) & 0b0000_0011,
      ]
    }
  }

  typealias Palette = [UInt8]

  enum TileMapAddress {
    case x9800 // 0
    case x9C00 // 1

    var address: LR35902.Address {
      switch self {
      case .x9800: return 0x9800
      case .x9C00: return 0x9C00
      }
    }
  }
  enum TileDataAddress {
    case x8800 // 0
    case x8000 // 1

    var address: LR35902.Address {
      switch self {
      case .x8800: return 0x8800 + 0x800  // Data is accessed using a signed int8, so offset to the center of the region
      case .x8000: return 0x8000
      }
    }
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

  enum LCDCMode {
    var bits: UInt8 {
      switch self {
      case .hblank:         return 0b0000_0000
      case .vblank:         return 0b0000_0001
      case .searchingOAM:   return 0b0000_0010
      case .pixelTransfer:  return 0b0000_0011
      }
    }

    case hblank         // Mode 0
    case vblank         // Mode 1
    case searchingOAM   // Mode 2
    case pixelTransfer  // Mode 3
  }
}
