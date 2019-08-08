import Foundation

public final class LR35902 {
  public var pc: UInt16 = 0
  public var bank: UInt8 = 0

  public init(rom: Data) {
    self.rom = rom
  }
  private let rom: Data

  // MARK: - Accessing ROM data

  public subscript(pc: UInt16, bank: UInt8) -> UInt8 {
    return rom[Int(LR35902.romAddress(for: pc, in: bank))]
  }

  public subscript(range: Range<UInt32>) -> Data {
    return rom[range]
  }

  /// Returns a ROM address for the given program counter and bank.
  /// - Parameter pc: The program counter's location.
  /// - Parameter bank: The current bank.
  public static func romAddress(for pc: UInt16, in bank: UInt8) -> UInt32 {
    if pc < 0x4000 {
      return UInt32(pc)
    } else {
      return UInt32(bank) * LR35902.bankSize + UInt32(pc - 0x4000)
    }
  }

  public var numberOfBanks: UInt8 {
    return UInt8(UInt32(rom.count) / LR35902.bankSize)
  }

  public let disassembly = Disassembly()

  struct BankedAddress: Hashable {
    let bank: UInt8
    let address: UInt16
  }

  static let bankSize: UInt32 = 0x4000
}
