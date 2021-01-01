import Foundation

extension LR35902.Emulation {
  final class sbc_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .sbc(.imm8) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        immediate = UInt8(memory.read(from: cpu.pc))
        cpu.pc += 1
        return .continueExecution
      }
      if cpu.fcarry {
        subWithCarry(cpu: cpu, value: immediate)
      } else {
        sub(cpu: cpu, value: immediate)
      }
      return .fetchNext
    }

    private var immediate: UInt8 = 0
  }
}
