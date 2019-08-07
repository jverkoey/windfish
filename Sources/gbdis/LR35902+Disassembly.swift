import Foundation

extension LR35902 {
  class Disassembly {
    init(size: UInt32) {
      self.memoryMap = (0..<size).map { _ in .unknown }
    }

    private var instructionMap: [UInt32: InstructionSpec] = [:]
    private var jumpMap: [UInt32: JumpKind] = [:]

    enum MemoryType {
      case unknown
      case code
    }
    private var memoryMap: [MemoryType]

    func register(instruction: InstructionSpec, at pc: UInt16, in bank: UInt8) {
      let index = UInt32(pc) + UInt32(bank) * LR35902.bankSize

      instructionMap[index] = instruction

      for memoryOffset in index..<(index + UInt32(instruction.byteWidth)) {
        memoryMap[Int(memoryOffset)] = .code
      }
    }

    enum JumpKind {
      case relative
      case absolute
    }
    func register(jumpAddress pc: UInt16, in bank: UInt8, kind: JumpKind) {
      let index = UInt32(pc) + UInt32(bank) * LR35902.bankSize
      jumpMap[index] = kind
    }
  }
}
