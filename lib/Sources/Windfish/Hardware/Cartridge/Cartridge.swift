import Foundation

protocol MemoryBankController: AddressableMemory {
  var selectedBank: Gameboy.Cartridge.Bank { get }
}

extension Gameboy {
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
      self.numberOfBanks = Gameboy.Cartridge.Bank((self.size + Gameboy.Cartridge.bankSize - 1) / Gameboy.Cartridge.bankSize)
    }

    /** The total number of banks in this cartridge. */
    public let numberOfBanks: Gameboy.Cartridge.Bank
    public let size: Length
    public var selectedBank: Gameboy.Cartridge.Bank {
      return memoryBankController.selectedBank
    }

    // MARK: - AddressableMemory

    public func read(from address: LR35902.Address) -> UInt8 {
      return memoryBankController.read(from: address)
    }

    public func write(_ byte: UInt8, to address: LR35902.Address) {
      memoryBankController.write(byte, to: address)
    }

    public func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
      return memoryBankController.sourceLocation(from: address)
    }

    private var memoryBankController: MemoryBankController
  }
}

// MARK: - Standard constants

extension Gameboy.Cartridge {
  /** The size of a bank within the cartridge. */
  static let bankSize: Length = 0x4000
}

// MARK: - Cartridge location translation

extension Gameboy.Cartridge {
  /**
   Returns a cartridge location for the given program counter and bank.
   - Parameter pc: The program counter's location.
   - Parameter bank: The current bank.
   */
  public static func location(for pc: LR35902.Address, in bank: Gameboy.Cartridge.Bank) -> Location? {
    // Bank 0 is permanently addressable from 0x0000...0x3FFF.
    // All other banks map from 0x4000...0x7FFF
    guard (bank == 0 && pc < 0x4000) || (bank > 0 && pc < 0x8000) else {
      return nil
    }
    if pc < 0x4000 {
      return Location(pc)
    } else {
      return Location(bank) * Gameboy.Cartridge.bankSize + Location(pc - 0x4000)
    }
  }

  /**
   Returns a cartridge location for the given program counter and bank, adjusting for common mistakes made when
   specifying banks.

   Specifically, if bank is provided as 0 then 1 is assumed.

   - Parameter pc: The program counter's location.
   - Parameter bank: The current bank.
   */
  public static func location(for pc: LR35902.Address, inHumanProvided bank: Gameboy.Cartridge.Bank) -> Location? {
    return location(for: pc, in: (bank == 0) ? 1 : bank)
  }

  /**
   Returns a cartridge address for the given program counter and bank.
   - Parameter pc: The program counter's location.
   - Parameter bank: The current bank.
   */
  public static func addressAndBank(from cartridgeLocation: Location) -> (address: LR35902.Address, bank: Gameboy.Cartridge.Bank) {
    let bank = Gameboy.Cartridge.Bank(cartridgeLocation / Gameboy.Cartridge.bankSize)
    let address = LR35902.Address(cartridgeLocation % Gameboy.Cartridge.bankSize + Location((bank > 0) ? 0x4000 : 0x0000))
    return (address: address, bank: bank)
  }
}
