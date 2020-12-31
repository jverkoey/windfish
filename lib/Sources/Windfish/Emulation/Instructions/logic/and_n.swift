import Foundation

extension LR35902.Emulation {
  final class and_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .and(.imm8) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        immediate = UInt8(memory.read(from: cpu.pc))
        cpu.pc += 1
        return .continueExecution
      }
      cpu.a &= immediate
      cpu.fzero = cpu.a == 0
      cpu.fsubtract = false
      cpu.fcarry = false
      cpu.fhalfcarry = true
      return .fetchNext
    }

    private var immediate: UInt8 = 0
  }
}
