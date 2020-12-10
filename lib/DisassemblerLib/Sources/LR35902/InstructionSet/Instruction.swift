import Foundation
import CPU

extension LR35902 {
  /** A concrete representation of a single LR35902 instruction. */
  public struct Instruction: CPU.Instruction, Hashable {
    public var spec: Spec

    public enum ImmediateValue: Hashable {
      case imm8(UInt8)
      case imm16(UInt16)
    }
    public let immediate: ImmediateValue?

    public init(spec: Spec, immediate: ImmediateValue? = nil) {
      self.spec = spec
      self.immediate = immediate
    }

    public func operandData() -> Data? {
      switch immediate {
      case let .imm8(value):
        return Data([value])
      case let .imm16(value):
        return Data([UInt8(value & 0xff), UInt8((value >> 8) & 0xff)])
      case .none:
        return nil
      }
    }
  }
}
