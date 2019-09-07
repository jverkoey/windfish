import Foundation

public final class LR35902 {
  public typealias Address = UInt16
  public typealias Bank = UInt8
  public typealias CartridgeLocation = UInt32

  public var pc: Address = 0
  public var bank: Bank = 0

  public init(cartridge: Data) {
    self.cartridge = cartridge
  }
  private let cartridge: Data
  var cartridgeSize: CartridgeLocation {
    return CartridgeLocation(cartridge.count)
  }

  // MARK: - Accessing ROM data

  public subscript(pc: Address, bank: Bank) -> UInt8 {
    return cartridge[Int(LR35902.cartAddress(for: pc, in: bank)!)]
  }

  public subscript(range: Range<CartridgeLocation>) -> Data {
    return cartridge[range]
  }

  /// Returns a cartridge address for the given program counter and bank.
  /// - Parameter pc: The program counter's location.
  /// - Parameter bank: The current bank.
  public static func cartAddress(for pc: Address, in bank: Bank) -> CartridgeLocation? {
    // Bank 0 is permanently addressable from 0x0000...0x3FFF.
    // All other banks map from 0x4000...0x7FFF
    guard (bank == 0 && pc < 0x4000) || (bank > 0 && pc < 0x8000) else {
      return nil
    }
    if pc < 0x4000 {
      return CartridgeLocation(pc)
    } else {
      return CartridgeLocation(bank) * bankSize + CartridgeLocation(pc - 0x4000)
    }
  }

  public static func safeCartAddress(for pc: Address, in bank: Bank) -> CartridgeLocation? {
    return cartAddress(for: pc, in: (bank == 0) ? 1 : bank)
  }

  /// Returns a cartridge address for the given program counter and bank.
  /// - Parameter pc: The program counter's location.
  /// - Parameter bank: The current bank.
  public static func addressAndBank(from cartAddress: CartridgeLocation) -> (address: Address, bank: Bank) {
    let bank = Bank(cartAddress / bankSize)
    let address = Address(cartAddress % bankSize + CartridgeLocation((bank > 0) ? 0x4000 : 0x0000))
    return (address: address, bank: bank)
  }

  /// Returns a specification at the given address, if a valid one exists.
  public func spec(at pc: Address, in bank: Bank) -> Instruction.Spec? {
    let byte = Int(self[pc, bank])
    let spec = Instruction.table[byte]
    switch spec {
    case .invalid:
      return nil
    case .cb:
      let byteCB = Int(self[pc + 1, bank])
      let cbInstruction = Instruction.tableCB[byteCB]
      if case .invalid = spec {
        return nil
      }
      return cbInstruction
    default:
      return spec
    }
  }

  /// Returns an instruction at the given address.
  public func instruction(at pc: Address, in bank: Bank, spec: Instruction.Spec) -> Instruction? {
    let instructionWidth = Instruction.widths[spec]!
    guard let location = LR35902.cartAddress(for: pc + instructionWidth.opcode, in: bank) else {
      return nil
    }
    switch instructionWidth.operand {
    case 1:
      if location >= cartridge.count {
        return nil
      }
      return Instruction(spec: spec, imm8: self[pc + instructionWidth.opcode, bank])
    case 2:
      if location + 1 >= cartridge.count {
        return nil
      }
      let low = Address(self[pc + instructionWidth.opcode, bank])
      let high = Address(self[pc + instructionWidth.opcode + 1, bank]) << 8
      let immediate16 = high | low
      return Instruction(spec: spec, imm16: immediate16)
    default:
      return Instruction(spec: spec)
    }
  }

  func pcIsValid() -> Bool {
    return
      ((bank == 0 && pc < 0x4000)
        || (bank != 0 && pc < 0x8000))
        && LR35902.cartAddress(for: pc, in: bank)! < cartridgeSize
  }

  public var numberOfBanks: Bank {
    return Bank(CartridgeLocation(cartridge.count) / LR35902.bankSize)
  }

  static let bankSize: CartridgeLocation = 0x4000
}
