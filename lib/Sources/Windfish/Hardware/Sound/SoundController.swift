import Foundation

public final class SoundController {
  var wavePattern = Data.init(count: SoundController.wavePatternRegion.count)

  enum RegisterAddress: LR35902.Address {
    case NR10 = 0xFF10
    case NR11 = 0xFF11
    case NR12 = 0xFF12
    case NR13 = 0xFF13
    case NR14 = 0xFF14
    case NR21 = 0xFF16
    case NR22 = 0xFF17
    case NR23 = 0xFF18
    case NR24 = 0xFF19
    case NR30 = 0xFF1A
    case NR31 = 0xFF1B
    case NR32 = 0xFF1C
    case NR33 = 0xFF1D
    case NR34 = 0xFF1E
    case NR41 = 0xFF20
    case NR42 = 0xFF21
    case NR43 = 0xFF22
    case NRSomething = 0xFF23
    case NR50 = 0xFF24
    case NR51 = 0xFF25
    case NR52 = 0xFF26
  }
  var values: [RegisterAddress: UInt8] = [
    .NR10: 0x80,
    .NR11: 0xBF,
    .NR12: 0xF3,
    .NR13: 0x00,
    .NR14: 0xBF,
    .NR21: 0x3F,
    .NR22: 0x00,
    .NR23: 0x00,
    .NR24: 0xBF,
    .NR30: 0x7F,
    .NR31: 0xFF,
    .NR32: 0x9F,
    .NR33: 0xBF,
    .NR34: 0xBF,
    .NR41: 0xFF,
    .NR42: 0x00,
    .NR43: 0x00,
    .NRSomething: 0xBF,
    .NR50: 0x77,
    .NR51: 0xF3,
    .NR52: 0xF1,
  ]
}

extension SoundController: AddressableMemory {
  static let soundRegistersRegion: ClosedRange<LR35902.Address> = 0xFF10...0xFF26
  static let wavePatternRegion: ClosedRange<LR35902.Address> = 0xFF30...0xFF3F

  public func read(from address: LR35902.Address) -> UInt8 {
    switch address {
    case SoundController.wavePatternRegion:
      return wavePattern[Int(address - SoundController.wavePatternRegion.lowerBound)]
    case SoundController.soundRegistersRegion:
      guard let register = RegisterAddress(rawValue: address) else {
        preconditionFailure("Invalid address")
      }
      return values[register]!
    default:
      fatalError()
    }
  }

  public func write(_ byte: UInt8, to address: LR35902.Address) {
    switch address {
    case SoundController.wavePatternRegion:
      wavePattern[Int(address - SoundController.wavePatternRegion.lowerBound)] = byte
    case SoundController.soundRegistersRegion:
      guard let register = RegisterAddress(rawValue: address) else {
        preconditionFailure("Invalid address")
      }
      values[register] = byte
    default:
      fatalError()
    }
  }

  public func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return .memory(address)
  }
}
