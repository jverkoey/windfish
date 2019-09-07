import Foundation
import CPU

extension LR35902 {
  /// A concrete representation of a single LR35902 instruction.
  public struct Instruction: CPU.Instruction {
    public var spec: Spec

    /// Only one of these immediate values may be associated with a given instruction.
    public let imm8: UInt8?
    public let imm16: UInt16?

    public init(spec: Spec) {
      self.spec = spec
      self.imm8 = nil
      self.imm16 = nil
    }

    public init(spec: Spec, imm8: UInt8) {
      self.spec = spec
      self.imm8 = imm8
      self.imm16 = nil
    }

    public init(spec: Spec, imm16: UInt16) {
      self.spec = spec
      self.imm8 = nil
      self.imm16 = imm16
    }

    public func operandData() -> Data? {
      if let imm8 = imm8 {
        return Data([imm8])
      }
      if let imm16 = imm16 {
        return Data([UInt8(imm16 & 0xff), UInt8((imm16 >> 8) & 0xff)])
      }
      return nil
    }
  }
}
