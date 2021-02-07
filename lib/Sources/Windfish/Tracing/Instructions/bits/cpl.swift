import Foundation

import LR35902

extension LR35902.Emulation {
  final class cpl: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cpl = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      cpu.fsubtract = true
      cpu.fhalfcarry = true

      guard let a = cpu.a else {
        cpu.a = nil
        return
      }
      cpu.a = ~a
    }
  }
}
