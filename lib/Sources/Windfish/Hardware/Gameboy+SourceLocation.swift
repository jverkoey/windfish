import Foundation

import LR35902

public final class Gameboy {
  /** A representation of a specific address either in the cartridge ROM or in memory. */
  public enum SourceLocation: Equatable {
    /** An address in the cartridge's ROM data. */
    case cartridge(Cartridge.Location)

    /** An address in the Gameboy's memory. */
    case memory(LR35902.Address)
  }

  /**
   Returns a source location for the given program counter and bank.

   - Parameter address: An address in the gameboy's memory.
   - Parameter bank: The selected bank.
   */
  static func sourceLocation(for address: LR35902.Address, in bank: Cartridge.Bank) -> SourceLocation {
    if address < 0x8000 {
      return .cartridge(Cartridge.Location(address: address, bank: bank))
    }
    return .memory(address)
  }
}
