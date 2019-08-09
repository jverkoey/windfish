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

  public func initializeDisassembly() {
    // Restart addresses
    let numberOfRestartAddresses = 8
    let restartSize = 8
    let rstAddresses = (0..<numberOfRestartAddresses)
      .map { UInt16($0 * restartSize)..<UInt16($0 * restartSize + restartSize) }
    rstAddresses.forEach {
      disassembly.setLabel(at: $0.lowerBound, in: 0x00, named: "RST_\($0.lowerBound.hexString)")
      disassemble(range: $0, inBank: 0)
    }

    disassembly.setLabel(at: 0x0040, in: 0x00, named: "VBlankInterrupt")
    disassemble(range: 0x0040..<0x0048, inBank: 0)

    disassembly.setLabel(at: 0x0048, in: 0x00, named: "LCDCInterrupt")
    disassemble(range: 0x0048..<0x0050, inBank: 0)

    disassembly.setLabel(at: 0x0050, in: 0x00, named: "TimerOverflowInterrupt")
    disassemble(range: 0x0050..<0x0058, inBank: 0)

    disassembly.setLabel(at: 0x0058, in: 0x00, named: "SerialTransferCompleteInterrupt")
    disassemble(range: 0x0058..<0x0060, inBank: 0)

    disassembly.setLabel(at: 0x0060, in: 0x00, named: "JoypadTransitionInterrupt")
    disassemble(range: 0x0060..<0x0068, inBank: 0)

    disassembly.setLabel(at: 0x0100, in: 0x00, named: "Boot")
    disassemble(range: 0x0100..<0x104, inBank: 0)

    disassembly.setLabel(at: 0x0104, in: 0x00, named: "HeaderLogo")
    disassembly.setData(at: 0x0104..<0x0134, in: 0x00)

    disassembly.setLabel(at: 0x0134, in: 0x00, named: "HeaderTitle")
    disassembly.setData(at: 0x0134..<0x0143, in: 0x00)
  }

  struct BankedAddress: Hashable {
    let bank: UInt8
    let address: UInt16
  }

  static let bankSize: UInt32 = 0x4000
}
