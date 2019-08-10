import Foundation

extension LR35902 {
  public struct Instruction: Equatable {
    public let spec: InstructionSpec
    public let width: UInt16
    public let immediate8: UInt8?
    public let immediate16: UInt16?

    init(spec: InstructionSpec, width: UInt16, immediate8: UInt8? = nil, immediate16: UInt16? = nil) {
      self.spec = spec
      self.width = width
      self.immediate8 = immediate8
      self.immediate16 = immediate16
    }
  }
}
