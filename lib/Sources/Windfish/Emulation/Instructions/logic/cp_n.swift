import Foundation

extension LR35902.Emulation {
  final class cp_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cp(.imm8) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        immediate = memory.read(from: cpu.pc)
        cpu.pc += 1
        return .continueExecution
      }
      cp(cpu: cpu, value: immediate)
      return .fetchNext
    }

    private var immediate: UInt8 = 0
  }
}
