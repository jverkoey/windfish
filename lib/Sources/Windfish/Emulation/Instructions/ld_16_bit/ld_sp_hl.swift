import Foundation

extension LR35902.Emulation {
  final class ld_sp_hl: InstructionEmulator {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.sp, .hl) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult {
      if cycle == 1 {
        cpu.sp = cpu.hl
        cpu.registerTraces[.sp] = cpu.registerTraces[.hl]
        return .continueExecution
      }
      return .fetchNext
    }
  }
}
