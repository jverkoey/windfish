import Foundation

extension LR35902 {
  /// A concrete representation of a single LR35902 instruction.
  public struct Instruction: Hashable, Equatable {
    public var spec: InstructionSpec

    /// Only one of these immediate values may be associated with a given instruction.
    public let imm8: UInt8?
    public let imm16: UInt16?

    public init(spec: InstructionSpec) {
      self.spec = spec
      self.imm8 = nil
      self.imm16 = nil
    }

    public init(spec: InstructionSpec, imm8: UInt8) {
      self.spec = spec
      self.imm8 = imm8
      self.imm16 = nil
    }

    public init(spec: InstructionSpec, imm16: UInt16) {
      self.spec = spec
      self.imm8 = nil
      self.imm16 = imm16
    }
  }
}
