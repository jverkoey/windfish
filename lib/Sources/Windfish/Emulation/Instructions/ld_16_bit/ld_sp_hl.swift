import Foundation

extension LR35902.Emulation {
  final class ld_sp_hl: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.sp, .hl) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      cpu.sp = cpu.hl
      cpu.registerTraces[.sp] = cpu.registerTraces[.hl]
    }
  }
}
