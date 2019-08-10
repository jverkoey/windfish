import Foundation

extension LR35902 {
  public struct Instruction: Hashable, Equatable {
    public let spec: InstructionSpec
    public let immediate8: UInt8?
    public let immediate16: UInt16?

    public init(spec: InstructionSpec, immediate8: UInt8? = nil, immediate16: UInt16? = nil) {
      self.spec = spec
      self.immediate8 = immediate8
      self.immediate16 = immediate16
    }
  }
}
