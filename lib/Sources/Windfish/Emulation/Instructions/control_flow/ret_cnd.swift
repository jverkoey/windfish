import Foundation

extension LR35902.Emulation {
  final class ret_cnd: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ret(let cnd) = spec else {
        return nil
      }
      self.cnd = cnd
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        return checkConditional(cnd: cnd, cpu: cpu)
      }
      if cycle == 2 {
        pc = UInt16(truncatingIfNeeded: memory.read(from: cpu.sp))
        cpu.sp += 1
        return .continueExecution
      }
      if cycle == 3 {
        pc |= UInt16(truncatingIfNeeded: memory.read(from: cpu.sp)) << 8
        cpu.sp += 1
        return .continueExecution
      }
      cpu.pc = pc
      return .fetchNext
    }

    private let cnd: LR35902.Instruction.Condition?
    private var pc: UInt16 = 0
  }
}
