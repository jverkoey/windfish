import Foundation
import CPU

extension LR35902 {
  /** A concrete representation of a single LR35902 instruction. */
  public struct Instruction: CPU.Instruction, Hashable {
    public init(spec: Spec, immediate: ImmediateValue? = nil) {
      self.spec = spec
      self.immediate = immediate
    }

    public let spec: Spec
    public let immediate: ImmediateValue?

    public enum ImmediateValue: CPU.InstructionImmediate {
      case imm8(UInt8)
      case imm16(UInt16)

      public init?(data: Data) {
        switch data.count {
        case 1:
          self = .imm8(data[0])
        case 2:
          let low = UInt16(data[0])
          let high = UInt16(data[1]) << 8
          let immediate16 = high | low
          self = .imm16(immediate16)
        default:
          return nil
        }
      }

      public func asData() -> Data {
        switch self {
        case let .imm8(immediate):
          return Data([immediate])
        case let .imm16(immediate):
          let low = UInt8(immediate & 0xFF)
          let high = UInt8((immediate >> 8) & 0xFF)
          return Data([low, high])
        }
      }

      public func asInt() -> Int {
        switch self {
        case let .imm8(immediate):  return Int(truncatingIfNeeded: immediate)
        case let .imm16(immediate): return Int(truncatingIfNeeded: immediate)
        }
      }
    }
  }
}
