import Foundation

import LR35902

/** A representation of a Gameboy cartridge as addressable memory at a given moment. */
public class Cartridge {
  public typealias Bank = UInt8
  public typealias Length = UInt32
}

// MARK: - Standard constants

extension Cartridge {
  /** The size of a bank within the cartridge. */
  public static let bankSize: Int = 0x4000
}

extension Cartridge {
  /** A location in a Gameboy ROM, as expressed by a banked address. */
  public final class Location {
    public let address: LR35902.Address
    public let bank: Cartridge.Bank

    /** Returns a zero-based bank index, where addresses below 0x4000 are treated as bank 0. */
    public var bankIndex: Cartridge.Bank {
      return address < 0x4000 ? 0 : bank
    }

    public lazy var index: Int = {
      (address < 0x4000)
        ? Int(truncatingIfNeeded: address)
        : Int(truncatingIfNeeded: bank) * Int(truncatingIfNeeded: 0x4000) + Int(truncatingIfNeeded: address - 0x4000)
    }()

    public init(address: LR35902.Address, bank: Cartridge.Bank) {
      self.address = address
      // Always pin addresses below 0x4000 to bank 1.
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
  public func asIntRange() -> Range<Int> {
    return Int(truncatingIfNeeded: lowerBound.index)..<Int(truncatingIfNeeded: upperBound.index)
  }
}
