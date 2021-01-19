import Foundation

protocol MemoryBankController: AddressableMemory {
  var selectedBank: Cartridge.Bank { get }
}

/** A representation of a Gameboy cartridge as addressable memory at a given moment. */
public class Cartridge: AddressableMemory {
  static let romBankRegion: ClosedRange<LR35902.Address> = 0x0000...0x7FFF
  static let ramBankRegion: ClosedRange<LR35902.Address> = 0xA000...0xBFFF

  public typealias Bank = UInt8
  public typealias Location = UInt32
  public typealias Length = UInt32

  /**
   Initializes the cartridge with the given data.

   The data in the cartridge defines how the cartridge handles access to it.
   */
  public init(data: Data) {
    // TODO: Read the data to determine which memory bank controller needs to be instantiated.
    self.memoryBankController = MBC1(data: data)

    self.size = Length(data.count)
    self.numberOfBanks = Cartridge.Bank((self.size + Cartridge.bankSize - 1) / Cartridge.bankSize)
  }

  /** The total number of banks in this cartridge. */
  public let numberOfBanks: Cartridge.Bank
  public let size: Length
  public var selectedBank: Cartridge.Bank {
    return memoryBankController.selectedBank
  }

  // MARK: - AddressableMemory

  public func read(from address: LR35902.Address) -> UInt8 {
    return memoryBankController.read(from: address)
  }

  public func write(_ byte: UInt8, to address: LR35902.Address) {
    memoryBankController.write(byte, to: address)
  }

  public func sourceLocation(from address: LR35902.Address) -> Gameboy.SourceLocation {
    return memoryBankController.sourceLocation(from: address)
  }

  private var memoryBankController: MemoryBankController
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
      return Location(pc)
    } else {
      return Location(bank) * Cartridge.bankSize + Location(pc - 0x4000)
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
