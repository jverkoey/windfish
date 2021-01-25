import Foundation

extension LR35902.Emulation {
  final class ld_sp_hl: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.sp, .hl) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      cpu.registerTraces[.sp] = cpu.registerTraces[.hl]

      cpu.sp = cpu.hl
    }
  }
}
