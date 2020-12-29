import Foundation

// References:
// - https://gekkio.fi/files/gb-docs/gbctr.pdf
// - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
// - https://github.com/Gekkio/mooneye-gb/
// - https://www.reddit.com/r/EmuDev/comments/5hahss/gb_readwrite_memory_during_an_oam_dma/

public final class DMAController {
  static let registerAddress: LR35902.Address = 0xFF46

  init(oam: OAM) {
    self.oam = oam
  }
  let oam: OAM

  var oamLocked = false
  private var running = false

  private var register: UInt8 = 0
  private var currentAddressLSB: UInt8 = 0
  private var starting = false
}

// MARK: - Emulation

extension DMAController {
  /** Executes a single machine cycle. */
  public func advance(memory: AddressableMemory) {
    // Use the last machine cycle to turn off the OAM lock.
    guard running else {
      oamLocked = false
      return
    }

    // Skip the first machine cycle so that the DMA transfer takes a total of 162 machine cycles.
    if starting {
      starting = false
      return
    }

    oamLocked = true

    let byte = memory.read(from: LR35902.Address(register) << 8 | LR35902.Address(currentAddressLSB))
    // Ignore any memory locks the LCD controller might have in place at this time and write directly to the OAM.
    oam.write(byte, to: 0xFE00 | LR35902.Address(currentAddressLSB))

    currentAddressLSB += 1
    if currentAddressLSB > 0x9F {
      running = false  // Note that we don't release the lock until the next machine cycle.
    }
  }
}

// MARK: - AddressableMemory

extension DMAController: AddressableMemory {
  public func read(from address: LR35902.Address) -> UInt8 {
    return register
  }

  public func write(_ byte: UInt8, to address: LR35902.Address) {
    register = byte
    running = true
    starting = true
    currentAddressLSB = 0x00
  }

  public func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return .memory(address)
  }
}
