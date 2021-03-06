import Foundation

import LR35902

extension LR35902.Emulation {
  final class jp_hl: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .jp(nil, .hl) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      // No trace needed.

      guard let hl: UInt16 = cpu.hl else {
        return
      }
      cpu.pc = hl
    }
  }
}
