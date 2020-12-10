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
    public enum ImmediateValue: Hashable {
      case imm8(UInt8)
      case imm16(UInt16)
    }
    public let immediate: ImmediateValue?
  }
}
