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

  /// Returns a cartridge address for the given program counter and bank.
  /// - Parameter pc: The program counter's location.
  /// - Parameter bank: The current bank.
  public static func addressAndBank(from cartAddress: CartridgeLocation) -> (address: Address, bank: Bank) {
    let bank = Bank(cartAddress / bankSize)
    let address = Address(cartAddress % bankSize + CartridgeLocation((bank > 0) ? 0x4000 : 0x0000))
    return (address: address, bank: bank)
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
