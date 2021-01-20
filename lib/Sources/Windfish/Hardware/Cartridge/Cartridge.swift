import Foundation

/** A representation of a Gameboy cartridge as addressable memory at a given moment. */
public class Cartridge {
  public typealias Bank = UInt8

  // TODO: Add conversion types for casting Location to banked address representations.
  public typealias Location = UInt32
  public typealias Length = UInt32
}

// MARK: - Standard constants

extension Cartridge {
  /** The size of a bank within the cartridge. */
  static let bankSize: Length = 0x4000
}

// MARK: - Cartridge location translation

extension Cartridge {
  /**
   Returns a cartridge location for the given program counter and bank.
   - Parameter pc: The program counter's location.
   - Parameter bank: The current bank.
   */
  public static func location(for pc: LR35902.Address, in bank: Cartridge.Bank) -> Location? {
    precondition(bank > 0)
    guard pc < 0x8000 else {
      return nil
    }
    if pc < 0x4000 {
      return Location(truncatingIfNeeded: pc)
    } else {
      return Location(truncatingIfNeeded: bank) * Cartridge.bankSize + Location(truncatingIfNeeded: pc - 0x4000)
    }
  }

  /**
   Returns a cartridge location for the given program counter and bank, adjusting for common mistakes made when
   specifying banks.

   Specifically, if bank is provided as 0 then 1 is assumed.

   - Parameter pc: The program counter's location.
   - Parameter bank: The current bank.
   */
  public static func location(for pc: LR35902.Address, inHumanProvided bank: Cartridge.Bank) -> Location? {
    return location(for: pc, in: max(1, bank))
  }

  /**
   Returns a cartridge address for the given program counter and bank.
   - Parameter pc: The program counter's location.
   - Parameter bank: The current bank.
   */
  public static func addressAndBank(from cartridgeLocation: Location) -> (address: LR35902.Address, bank: Cartridge.Bank) {
    let bank = Cartridge.Bank(cartridgeLocation / Cartridge.bankSize)
    let address = LR35902.Address(cartridgeLocation % Cartridge.bankSize + Location((bank > 0) ? 0x4000 : 0x0000))
    return (address: address, bank: max(1, bank))
  }
}
