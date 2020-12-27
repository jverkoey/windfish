import Foundation

// References:
// - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf

public struct IORegisterMemory: AddressableMemory {
  public let addressableRanges: [ClosedRange<LR35902.Address>] = [
    0xFF05...0xFF26,
    0xFF47...0xFF4B,
    0xFFFF...0xFFFF
  ]

  enum IOAddresses: LR35902.Address {
    case TIMA = 0xFF05
    case TMA  = 0xFF06
    case TAC  = 0xFF07
    case IF   = 0xFF0F
    case NR10 = 0xFF10
    case NR11 = 0xFF11
    case NR12 = 0xFF12
    case NR14 = 0xFF14
    case NR21 = 0xFF16
    case NR22 = 0xFF17
    case NR24 = 0xFF19
    case NR30 = 0xFF1A
    case NR31 = 0xFF1B
    case NR32 = 0xFF1C
    case NR33 = 0xFF1E
    case NR41 = 0xFF20
    case NR42 = 0xFF21
    case NR43 = 0xFF22
    case NRSomething = 0xFF23
    case NR50 = 0xFF24
    case NR51 = 0xFF25
    case NR52 = 0xFF26
    case BGP  = 0xFF47
    case OBP0 = 0xFF48
    case OBP1 = 0xFF49
    case WY   = 0xFF4A
    case WX   = 0xFF4B
    case IE   = 0xFFFF
  }
  var values: [IOAddresses: UInt8] = [
    .TIMA: 0x00,
    .TMA:  0x00,
    .TAC:  0x00,
    .IF:   0x00,
    .NR10: 0x80,
    .NR11: 0xBF,
    .NR12: 0xF3,
    .NR14: 0xBF,
    .NR21: 0x3F,
    .NR22: 0x00,
    .NR24: 0xBF,
    .NR30: 0x7F,
    .NR31: 0xFF,
    .NR32: 0x9F,
    .NR33: 0xBF,
    .NR41: 0xFF,
    .NR42: 0x00,
    .NR43: 0x00,
    .NRSomething: 0xBF,
    .NR50: 0x77,
    .NR51: 0xF3,
    .NR52: 0xF1,
    .BGP:  0xFC,
    .OBP0: 0xFF,
    .OBP1: 0xFF,
    .WY:   0x00,
    .WX:   0x00,
    .IE:   0x00,
  ]
  public func read(from address: LR35902.Address) -> UInt8 {
    guard let ioAddress = IOAddresses(rawValue: address) else {
      preconditionFailure("Invalid address")
    }
    return values[ioAddress]!
  }

  public mutating func write(_ byte: UInt8, to address: LR35902.Address) {
    guard let ioAddress = IOAddresses(rawValue: address) else {
      preconditionFailure("Invalid address")
    }
    precondition(values[ioAddress] != nil, "Writing to invalid register.")
    values[ioAddress] = byte
  }

  public func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return .memory(address)
  }
}
