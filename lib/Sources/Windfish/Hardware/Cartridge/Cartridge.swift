import Foundation

/** A representation of a Gameboy cartridge as addressable memory at a given moment. */
public class Cartridge {
  public typealias Bank = UInt8

  // TODO: Add conversion types for casting Location to banked address representations.
  public typealias _Location = UInt32
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
  public static func location(for pc: LR35902.Address, in bank: Cartridge.Bank) -> _Location? {
    precondition(bank > 0)
    guard pc < 0x8000 else {
      return nil
    }
    if pc < 0x4000 {
      return _Location(truncatingIfNeeded: pc)
    } else {
      return _Location(truncatingIfNeeded: bank) * Cartridge.bankSize + _Location(truncatingIfNeeded: pc - 0x4000)
    }
  }

  /**
   Returns a cartridge location for the given program counter and bank, adjusting for common mistakes made when
   specifying banks.

   Specifically, if bank is provided as 0 then 1 is assumed.

   - Parameter pc: The program counter's location.
   - Parameter bank: The current bank.
   */
  public static func location(for pc: LR35902.Address, inHumanProvided bank: Cartridge.Bank) -> _Location? {
    return location(for: pc, in: max(1, bank))
  }

  /**
   Returns a cartridge address for the given program counter and bank.
   - Parameter pc: The program counter's location.
   - Parameter bank: The current bank.
   */
  public static func addressAndBank(from cartridgeLocation: _Location) -> (address: LR35902.Address, bank: Cartridge.Bank) {
    let bank = Cartridge.Bank(cartridgeLocation / Cartridge.bankSize)
    let address = LR35902.Address(cartridgeLocation % Cartridge.bankSize + _Location((bank > 0) ? 0x4000 : 0x0000))
    return (address: address, bank: max(1, bank))
  }
}

extension Cartridge {
  public final class Location {
    let address: LR35902.Address
    let bank: Cartridge.Bank

    lazy var index: Int = {
      (address < 0x4000)
        ? Int(truncatingIfNeeded: address)
        : Int(truncatingIfNeeded: bank) * Int(truncatingIfNeeded: 0x4000) + Int(truncatingIfNeeded: address - 0x4000)
    }()

    public init(address: LR35902.Address, bank: Cartridge.Bank) {
      self.address = address
      self.bank = max(1, bank)
    }

    public static func + (lhs: Cartridge.Location, rhs: Int) -> Cartridge.Location {
      return lhs + LR35902.Address(truncatingIfNeeded: rhs)
    }

    public static func + (lhs: Cartridge.Location, rhs: LR35902.Address) -> Cartridge.Location {
      return Cartridge.Location(address: lhs.address + rhs, bank: lhs.bank)
    }
  }
}

extension Cartridge.Location: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(bank)
    hasher.combine(address)
  }
}

extension Cartridge.Location: Equatable {
  public static func == (lhs: Cartridge.Location, rhs: Cartridge.Location) -> Bool {
    return lhs.index == rhs.index
  }
}

extension Cartridge.Location: Comparable {
  public static func < (lhs: Cartridge.Location, rhs: Cartridge.Location) -> Bool {
    return lhs.index < rhs.index
  }
}

extension Cartridge.Location: Strideable {
  public func advanced(by n: Int) -> Cartridge.Location {
    return self + n
  }

  public func distance(to other: Cartridge.Location) -> Int {
    return other.index - index
  }
}

extension Range where Bound == Cartridge.Location {
  func asIntRange() -> Range<Int> {
    return Int(truncatingIfNeeded: lowerBound.index)..<Int(truncatingIfNeeded: upperBound.index)
  }
}
