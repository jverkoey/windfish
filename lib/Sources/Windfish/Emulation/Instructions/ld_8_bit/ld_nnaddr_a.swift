import Foundation

extension LR35902.Emulation {
  final class ld_nnaddr_a: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.imm16addr, .a) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        immediate = UInt16(truncatingIfNeeded: memory.read(from: cpu.pc))
        cpu.pc += 1
        return .continueExecution
      }
      if cycle == 2 {
        immediate |= UInt16(truncatingIfNeeded: memory.read(from: cpu.pc)) << 8
        cpu.pc += 1
        return .continueExecution
      }
      if cycle == 3 {
        memory.write(cpu.a, to: immediate)
        return .continueExecution
      }
      return .fetchNext
    }

    private var immediate: UInt16 = 0
  }
}
