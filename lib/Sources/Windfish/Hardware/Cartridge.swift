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
  static let bankSize: Int = 0x4000
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
      return _Location(truncatingIfNeeded: bank) * 0x4000 + _Location(truncatingIfNeeded: pc - 0x4000)
    }
  }
}

extension Cartridge {
  /** A location in a Gameboy ROM, as expressed by a banked address. */
  public final class Location {
    public let address: LR35902.Address
    public let bank: Cartridge.Bank

    lazy var index: Int = {
      (address < 0x4000)
        ? Int(truncatingIfNeeded: address)
        : Int(truncatingIfNeeded: bank) * Int(truncatingIfNeeded: 0x4000) + Int(truncatingIfNeeded: address - 0x4000)
    }()

    public init(address: LR35902.Address, bank: Cartridge.Bank) {
      self.address = address
      self.bank = address < 0x4000 ? 1 : max(1, bank)
    }

    public convenience init(address: Int, bank: Int) {
      self.init(address: LR35902.Address(truncatingIfNeeded: address), bank: Cartridge.Bank(truncatingIfNeeded: bank))
    }

    public convenience init(index: Int) {
      let bank = Cartridge.Bank(truncatingIfNeeded: index / Cartridge.bankSize)
      let address = LR35902.Address(index % Cartridge.bankSize + ((bank > 0) ? 0x4000 : 0))
      self.init(address: address, bank: bank)
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
    hasher.combine(index)
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
