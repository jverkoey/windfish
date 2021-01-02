import Foundation

extension LR35902.Emulation {
  final class ld_nnaddr_sp: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.imm16addr, .sp) = spec else {
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
        memory.write(UInt8(cpu.sp & 0x00FF), to: immediate)
        return .continueExecution
      }
      if cycle == 4 {
        memory.write(UInt8((cpu.sp & 0xFF00) >> 8), to: immediate + 1)
        return .continueExecution
      }
      return .fetchNext
    }

    private var immediate: UInt16 = 0
  }
}
