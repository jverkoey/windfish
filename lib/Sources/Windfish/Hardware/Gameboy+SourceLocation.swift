import Foundation

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
    precondition(bank > 0)
    if let cartridgeLocation = Cartridge.location(for: address, in: bank) {
      return .cartridge(cartridgeLocation)
    }
    return .memory(address)
  }
}
