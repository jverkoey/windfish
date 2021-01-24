import Foundation

extension LR35902.Emulation {
  final class ret_cnd: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ret(let cnd) = spec, cnd != nil else {
        return nil
      }
      self.cnd = cnd
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      if passesCondition(cnd: cnd, cpu: cpu) {
        pc = UInt16(truncatingIfNeeded: memory.read(from: cpu.sp))
        cpu.sp &+= 1
        pc |= UInt16(truncatingIfNeeded: memory.read(from: cpu.sp)) << 8
        cpu.sp &+= 1
        cpu.pc = pc
      }
    }

    private let cnd: LR35902.Instruction.Condition?
    private var pc: UInt16 = 0
  }
}
