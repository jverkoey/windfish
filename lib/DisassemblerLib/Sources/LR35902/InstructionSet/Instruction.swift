import Foundation
import CPU

extension LR35902 {
  /** A concrete representation of a single LR35902 instruction. */
  public struct Instruction: CPU.Instruction, Hashable {
    public init(spec: Spec, immediate: ImmediateValue? = nil) {
      self.spec = spec
      self.immediate = immediate
    }

    public var spec: Spec
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

    }
  }
}
