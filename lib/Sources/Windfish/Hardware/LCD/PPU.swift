import Foundation

// References:
// - https://www.youtube.com/watch?v=HyzD8pNlpwI&t=29m19s
// - https://gbdev.gg8.se/wiki/articles/Video_Display#FF41_-_STAT_-_LCDC_Status_.28R.2FW.29
// - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
// - http://gameboy.mongenel.com/dmg/asmmemmap.html
// - https://hacktix.github.io/GBEDG/ppu/#the-concept-of-scanlines
// - https://blog.tigris.fr/2019/09/15/writing-an-emulator-the-first-pixel/

protocol PPUMode {
  func start()
  /** Executes a single machine cycle.  */
  func advance(memory: AddressableMemory) -> PPU.LCDCMode?
}

public final class PPU {
  static let tileMapRegion: ClosedRange<LR35902.Address> = 0x9800...0x9FFF
  static let tileDataRegion: ClosedRange<LR35902.Address> = 0x8000...0x97FF
  static let registerRegion1: ClosedRange<LR35902.Address> = 0xFF40...0xFF45
  static let registerRegion2: ClosedRange<LR35902.Address> = 0xFF47...0xFF4B

  init(oam: OAM) {
    self.oam = oam
    self.modeOAMSearch = OAMSearchMode(oam: oam, registers: registers, lineCycleDriver: lineCycleDriver)
    self.modeVBlank = VBlankMode(registers: registers, lineCycleDriver: lineCycleDriver)
    self.modeHBlank = HBlankMode(registers: registers, lineCycleDriver: lineCycleDriver)
    self.modePixelTransfer = PixelTransferMode(registers: registers, lineCycleDriver: lineCycleDriver)
  }

  let oam: OAM
  let registers = LCDRegisters()

  /** An executable representation of the LCDMode register. */
  private var mode: PPUMode {
    get {
      // If a deferred mode has been set we prefer that over what's actually in the register.
      switch deferredLCDMode ?? registers.lcdMode {
      case .searchingOAM:   return modeOAMSearch
      case .vblank:         return modeVBlank
      case .pixelTransfer:  return modePixelTransfer
      case .hblank:         return modeHBlank
      }
    }
  }
  private let modeOAMSearch: OAMSearchMode
  private let modeVBlank: VBlankMode
  private let modeHBlank: HBlankMode
  private let modePixelTransfer: PixelTransferMode

  var bufferToggle = false
  public static let screenSize = (width: 160, height: 144)

  final class LineCycleDriver {
    var cycles: Int = 0

    /**
     The effective scanline of the PPU.

     This value typically equals ly, but in some cases deviates when ly. See the advance method for detailed timing on
     this behavior.
     */
    var scanline: UInt8 = 0
  }
  private let lineCycleDriver = LineCycleDriver()

  /**
   LCD Mode gets synchronized to the register on the second cycle of the mode.

   This value is set to the register on the subsequent machine instruction from which it was set.

   Resources:
   - Section 8.9. "LY, LYC, STAT and IF Timings. STAT LY=LYC interrupt" in https://github.com/AntonioND/giibiiadvance/blob/master/docs/TCAGBD.pdf

   Note the timing charts below, in which STAT mode is updated one machine cycle into the relevant phase. The M-clocks
   indicates the cycle count at the start of a single machine cycle advance. | is used to indicate a mode change.

   ## Line 0...143
   ```
              | OAM Search             | Pixel Transfer  | H-Blank
   M-clocks   | 0   1   2   3   ...  19| 20  21  22  23 ... 112 113
   STAT mode  | 0   2   2   2         2|  2   3   3   3       0   0
   ```

   ## Line 144
   ```
              | VBlank
   M-clocks   | 0   1   2   3   ...  19  20  21  22  23 ... 112 113
   STAT mode  | 0   1   1   1         1   1   1   1   1       1   1
   ```

   ## Line 145...153
   ```
                ...continuation of VBlank
   M-clocks     0   1   2   3   ...  19  20  21  22  23 ... 112 113
   STAT mode    1   1   1   1         1   1   1   1   1       1   1
   ```
   */
  private var deferredLCDMode: LCDCMode?

  /**
   The ly value that should be used for ly==lyc comparison.

   This always shows the value of ly from one machine cycle prior.
   */
  private var lyForComparison: UInt8 = 0

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

  /**
   Incremented every time a new vblank occurs.

   Primarily used by the emulator to observe whether a new vblank has occurred and to extract the vram data if so.
   */
  public private(set) var vblankCounter: Int = 0
}

// MARK: - Emulation

extension PPU {
  static let searchingOAMLength = 20
  static let scanlineCycleLength = 114

  /** Executes a single machine cycle. */
  public func advance(memory: AddressableMemory) {
    // The entire PPU stops executing when lcdDisplayEnable is disabled.
    // - https://www.reddit.com/r/Gameboy/comments/a1c8h0/what_happens_when_a_gameboy_screen_is_disabled/eap4f8c/?utm_source=reddit&utm_medium=web2x&context=3
    // - https://github.com/trekawek/coffee-gb/blob/088b86fb17109b8cac98e6394108b3561f443d54/src/main/java/eu/rekawek/coffeegb/gpu/Gpu.java#L171-L173
    // - https://github.com/spec-chum/SpecBoy/blob/5d1294d77648897a2a218a7fdcc33fbeb1e79038/SpecBoy/Ppu.cs#L214-L217
    guard registers.lcdDisplayEnable else {
      return
    }

    // See docs of deferredLCDMode for more details on this timing.
    if let deferredLCDMode = deferredLCDMode {
      registers.lcdMode = deferredLCDMode
      self.deferredLCDMode = nil
    }

    // Advance the state machine.
    if let nextMode = self.mode.advance(memory: memory) {
      if registers.lcdMode == .searchingOAM && nextMode == .pixelTransfer {
        // Modes aren't directly aware of each others' existence, so we copy the intersected OAMs to the pixel transfer
        // mode to keep a clear separation of concerns.
        modePixelTransfer.intersectedOAMs = modeOAMSearch.intersectedOAMs
      }
      if nextMode == .vblank {
        vblankCounter += 1  // Signal to observers of the emulator that vblank has been entered.
      }
      changeMode(to: nextMode)
    }

    /**
     ly == lyc interrupt flag gets set on a specific cycle depending on the line:

     ## Line 0
     ```
                | OAM Search             | Pixel Transfer  | H-Blank
     M-clocks   | 0   1   2   3   ...  19| 20  21  22  23 ... 112 113
     LY         | 0   0   0   0         0|  0   0   0   0       0   0
     LY for LYC | 0   0   0   0         0|  0   0   0   0       0   0
     IF LY==LYC |                        |
     ```

     ## Line 1-143
     ```
                | OAM Search             | Pixel Transfer  | H-Blank
     M-clocks   | 0   1   2   3   ...  19| 20  21  22  23 ... 112 113
     LY         |13  13  13  13        13| 13  13  13  13      13  13
     LY for LYC |    13  13  13        13| 13  13  13  13      13  13
     IF LY==LYC |     1                  |
     ```

     ## Line 144-152
     ```
                | V-Blank
     M-clocks   |  0   1   2   3   ...  19| 20  21  22  23 ... 112 113
     LY         |144 144 144 144       144|144 144 144 144     144 144
     LY for LYC |    144 144 144       144|144 144 144 144     144 144
     IF LY==LYC |      1                  |
     ```

     ## Line 153
     ```
                | V-Blank
     M-clocks   |  0   1   2   3   ...  19| 20  21  22  23 ... 112 113
     LY         |153   0   0   0         0|  0   0   0   0       0   0
     LY for LYC |    153       0         0|  0   0   0   0       0   0
     IF LY==LYC |      1       1          |
     ```

     Key points:
     - Line 0: No LY==LYC interrupt fired
     - Lines 1...152: LY==LYC interrupt fired on second machine cycle of the line
     - Line 153: LY==LYC interrupt fired twice; once for 

     Resources:
     - "8.9.1. Timings in DMG" in https://github.com/AntonioND/giibiiadvance/blob/master/docs/TCAGBD.pdf
    */

    precondition(lineCycleDriver.scanline >= 0 && lineCycleDriver.scanline <= 153, "Scanline is out of bounds.")

    // Flush the scanline to ly
    if lineCycleDriver.scanline < 153 {
      registers.ly = lineCycleDriver.scanline
    } else if lineCycleDriver.scanline == 153 {
      if lineCycleDriver.cycles <= 1 {
        registers.ly = lineCycleDriver.scanline
      } else {
        registers.ly = 0  // Force ly to 0 for the remainder of this line.
      }
    }

    // Update coincidence
    if lineCycleDriver.cycles == 1 || (lineCycleDriver.cycles == 3 && lineCycleDriver.scanline == 153) {
      // Coincidence is always off when the hardware is loading LY for comparison.
      registers.coincidence = false
    } else {
      // At all other times, coincidence should reflect equality of the last cycle's ly value and lyc.
      registers.coincidence = lyForComparison == registers.lyc
    }

    // Fire interrupts
    if lineCycleDriver.scanline >= 1 && lineCycleDriver.scanline <= 153 && lineCycleDriver.cycles == 2 {
      // Always fire on the second cycle of the line.
      requestCoincidenceInterruptIfNeeded(memory: memory)
    } else if lineCycleDriver.scanline == 153 && (lineCycleDriver.cycles == 2 || lineCycleDriver.cycles == 4) {
      // Except on line 153, which fires on cycle 2 for ly==lyc==153 and on cycle 4 for ly==lyc==0
      requestCoincidenceInterruptIfNeeded(memory: memory)
    }

    // Queue up LY for comparison for the next machine cycle
    lyForComparison = registers.ly
  }

  private func requestCoincidenceInterruptIfNeeded(memory: AddressableMemory) {
    if registers.coincidence && registers.enableCoincidenceInterrupt {
      registers.raiseLCDStatInterrupt(memory: memory)
    }
  }

  private func changeMode(to mode: LCDCMode) {
    // See docs of deferredLCDMode for more details on this timing.
    deferredLCDMode = mode

    self.mode.start()
  }
}

// MARK: - AddressableMemory

extension PPU: AddressableMemory {
  private func VRAMIsAccessible() -> Bool {
    // "When the LCD display is off you can write to video memory at any time with out restrictions. While it is on you
    // can only write to video memory during H-Blank and V-Blank."
    // - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
    // - https://github.com/spec-chum/SpecBoy/blob/master/SpecBoy/Ppu.cs#L132-L142
    // Note that coffee-gb appears to have disabled any of these checks and always allows VRAM access.
    // - https://github.com/trekawek/coffee-gb/blob/088b86fb17109b8cac98e6394108b3561f443d54/src/main/java/eu/rekawek/coffeegb/gpu/Gpu.java#L94
    // Sameboy allows read/write to be selectively enabled/disabled depending on hardware.
    // - https://github.com/LIJI32/SameBoy/blob/29a3b18186c181399f4b99b9111ca9d8b5726886/Core/display.c#L992-L993
    return !registers.lcdDisplayEnable || registers.lcdMode != .pixelTransfer
  }

  private func OAMIsAccessible() -> Bool {
    // "Cannot access OAM during OAM search or pixel transfer because that's when sprites are drawn."
    // - https://youtu.be/HyzD8pNlpwI?t=2879
    return registers.lcdMode != .searchingOAM && registers.lcdMode != .pixelTransfer
  }

  public func read(from address: LR35902.Address) -> UInt8 {
    if PPU.tileMapRegion.contains(address) {
      guard VRAMIsAccessible() else {
        return 0xFF
      }
      return registers.tileMap[Int(address - PPU.tileMapRegion.lowerBound)]
    }
    if PPU.tileDataRegion.contains(address) {
      guard VRAMIsAccessible() else {
        return 0xFF
      }
      return registers.tileData[Int(address - PPU.tileDataRegion.lowerBound)]
    }
    if OAM.addressableRange.contains(address) {
      guard OAMIsAccessible() else {
        return 0xFF  // OAM are only accessible during hblank and vblank
      }
      return oam.read(from: address)
    }

    guard let lcdAddress = Addresses(rawValue: address) else {
      preconditionFailure("Invalid address")
    }

    if registers.lcdMode == .pixelTransfer {
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

    case .SCY:  return registers.scy
    case .SCX:  return registers.scx

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

  public func write(_ byte: UInt8, to address: LR35902.Address) {
    if PPU.tileMapRegion.contains(address) {
      guard VRAMIsAccessible() else {
        return
      }
      registers.tileMap[Int(address - PPU.tileMapRegion.lowerBound)] = byte
      return
    }
    if PPU.tileDataRegion.contains(address) {
      guard VRAMIsAccessible() else {
        return
      }
      registers.tileData[Int(address - PPU.tileDataRegion.lowerBound)] = byte
      return
    }
    if OAM.addressableRange.contains(address) {
      guard OAMIsAccessible() else {
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

    if registers.lcdMode == .pixelTransfer {
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
        lineCycleDriver.scanline = 0
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

    case .SCY:  registers.scy = byte
    case .SCX:  registers.scx = byte

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
