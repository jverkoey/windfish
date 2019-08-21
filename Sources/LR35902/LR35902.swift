import Foundation

public final class LR35902 {
  public typealias Address = UInt16
  public typealias Bank = UInt8
  public typealias CartridgeAddress = UInt32

  public var pc: Address = 0
  public var bank: Bank = 0

  public init(cartridge: Data) {
    self.cartridge = cartridge
  }
  private let cartridge: Data
  var cartridgeSize: CartridgeAddress {
    return CartridgeAddress(cartridge.count)
  }

  // MARK: - Accessing ROM data

  public subscript(pc: Address, bank: Bank) -> UInt8 {
    return cartridge[Int(LR35902.cartAddress(for: pc, in: bank))]
  }

  public subscript(range: Range<CartridgeAddress>) -> Data {
    return cartridge[range]
  }

  /// Returns a cartridge address for the given program counter and bank.
  /// - Parameter pc: The program counter's location.
  /// - Parameter bank: The current bank.
  public static func cartAddress(for pc: Address, in bank: Bank) -> CartridgeAddress {
    if pc < 0x4000 {
      return CartridgeAddress(pc)
    } else {
      return CartridgeAddress(bank) * bankSize + CartridgeAddress(pc - 0x4000)
    }
  }

  func pcIsValid() -> Bool {
    return
      ((bank == 0 && pc < 0x4000)
        || (bank != 0 && pc < 0x8000))
        && LR35902.cartAddress(for: pc, in: bank) < cartridgeSize
  }

  public var numberOfBanks: Bank {
    return Bank(CartridgeAddress(cartridge.count) / LR35902.bankSize)
  }

  static let bankSize: CartridgeAddress = 0x4000
}
