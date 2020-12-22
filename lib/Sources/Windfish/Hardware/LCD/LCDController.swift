import Foundation

public struct LCDController: AddressableMemory {
  public let addressableRanges: [ClosedRange<LR35902.Address>] = [
    0xFF40...0xFF45
  ]

  enum Addresses: LR35902.Address {
    case LCDC = 0xFF40
    case STAT = 0xFF41
    case SCY  = 0xFF42
    case SCX  = 0xFF43
    case LY   = 0xFF44
    case LYC  = 0xFF45
  }
  var values: [Addresses: UInt8] = [
    .LCDC: 0x91,
    .STAT: 0x00,
    .SCY:  0x00,
    .SCX:  0x00,
    .LY:   0x00,
    .LYC:  0x00,
  ]
  public func read(from address: LR35902.Address) -> UInt8 {
    guard let lcdAddress = Addresses(rawValue: address) else {
      preconditionFailure("Invalid address")
    }
    return values[lcdAddress]!
  }

  public mutating func write(_ byte: UInt8, to address: LR35902.Address) {
    guard let lcdAddress = Addresses(rawValue: address) else {
      preconditionFailure("Invalid address")
    }
    return values[lcdAddress] = byte
  }
}
