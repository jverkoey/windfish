import Foundation

import LR35902

extension LR35902.Emulation {
  final class scf: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .scf = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // cpu.fzero is not affected
      cpu.fsubtract = false
      cpu.fhalfcarry = false
      cpu.fcarry = true
    }
  }
}
