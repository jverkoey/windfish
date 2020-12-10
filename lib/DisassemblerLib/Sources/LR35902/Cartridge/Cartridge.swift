import Foundation

extension LR35902 {
  public final class Cartridge {
    public typealias Location = UInt32

    public init(rom: Data) {
      self.rom = rom
    }

    // MARK: Internal storage
    private let rom: Data
  }
}

// MARK: - Information about the ROM

extension LR35902.Cartridge {
  /** Returns the number of banks in the loaded cartridge. */
  public var numberOfBanks: LR35902.Bank {
    return LR35902.Bank((Location(rom.count) + LR35902.bankSize - 1) / LR35902.bankSize)
  }
}

// MARK: - Accessing ROM data

extension LR35902.Cartridge {
  public subscript(pc: LR35902.Address, bank: LR35902.Bank) -> UInt8 {
    return rom[Int(LR35902.Cartridge.cartridgeLocation(for: pc, in: bank)!)]
  }

  public subscript(range: Range<Location>) -> Data {
    return rom[range]
  }
}

// MARK: - Working with locations

extension LR35902.Cartridge {
  /// Returns a cartridge location for the given program counter and bank.
  /// - Parameter pc: The program counter's location.
  /// - Parameter bank: The current bank.
  public static func cartridgeLocation(for pc: LR35902.Address, in bank: LR35902.Bank) -> Location? {
    // Bank 0 is permanently addressable from 0x0000...0x3FFF.
    // All other banks map from 0x4000...0x7FFF
    guard (bank == 0 && pc < 0x4000) || (bank > 0 && pc < 0x8000) else {
      return nil
    }
    if pc < 0x4000 {
      return Location(pc)
    } else {
      return Location(bank) * LR35902.bankSize + Location(pc - 0x4000)
    }
  }

  public static func safeCartridgeLocation(for pc: LR35902.Address, in bank: LR35902.Bank) -> Location? {
    return cartridgeLocation(for: pc, in: (bank == 0) ? 1 : bank)
  }

  /// Returns a cartridge address for the given program counter and bank.
  /// - Parameter pc: The program counter's location.
  /// - Parameter bank: The current bank.
  public static func addressAndBank(from cartridgeLocation: Location) -> (address: LR35902.Address, bank: LR35902.Bank) {
    let bank = LR35902.Bank(cartridgeLocation / LR35902.bankSize)
    let address = LR35902.Address(cartridgeLocation % LR35902.bankSize + Location((bank > 0) ? 0x4000 : 0x0000))
    return (address: address, bank: bank)
  }

  public static func rangeOf(bank: LR35902.Bank) -> (location: Location, length: Location) {
    return (Location(bank) * Location(LR35902.bankSize), LR35902.bankSize)
  }
}

// MARK: - Extracting instructions from the ROM

extension LR35902.Cartridge {
  /// Returns a specification at the given address, if a valid one exists.
  public func spec(at pc: LR35902.Address, in bank: LR35902.Bank) -> LR35902.Instruction.Spec? {
    let byte = Int(self[pc, bank])
    let spec = LR35902.InstructionSet.table[byte]
    switch spec {
    case .invalid:
      return nil
    case .cb:
      let byteCB = Int(self[pc + 1, bank])
      let cbInstruction = LR35902.InstructionSet.tableCB[byteCB]
      if case .invalid = spec {
        return nil
      }
      return cbInstruction
    default:
      return spec
    }
  }

  /// Returns an instruction at the given address.
  public func instruction(at pc: LR35902.Address, in bank: LR35902.Bank, spec: LR35902.Instruction.Spec) -> LR35902.Instruction? {
    let instructionWidth = LR35902.InstructionSet.widths[spec]!
    guard let location = LR35902.Cartridge.cartridgeLocation(for: pc + instructionWidth.opcode, in: bank) else {
      return nil
    }
    switch instructionWidth.operand {
    case 1:
      if location >= rom.count {
        return nil
      }
      return LR35902.Instruction(spec: spec, immediate: .imm8(self[pc + instructionWidth.opcode, bank]))
    case 2:
      if location + 1 >= rom.count {
        return nil
      }
      let low = LR35902.Address(self[pc + instructionWidth.opcode, bank])
      let high = LR35902.Address(self[pc + instructionWidth.opcode + 1, bank]) << 8
      let immediate16 = high | low
      return LR35902.Instruction(spec: spec, immediate: .imm16(immediate16))
    default:
      return LR35902.Instruction(spec: spec)
    }
  }
}

// MARK: - Internal methods

extension LR35902.Cartridge {
  var size: Location {
    return Location(rom.count)
  }
}
