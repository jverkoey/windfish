import Foundation

import LR35902

extension LR35902.Emulation {
  final class rla: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .rla = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      // No trace needed.

      cpu.fzero = false
      cpu.fsubtract = false
      cpu.fhalfcarry = false

      guard let a: UInt8 = cpu.a,
            let fcarry: Bool = cpu.fcarry else {
        cpu.fcarry = nil
        cpu.a = nil
        return
      }
      let carry = (a & 0b1000_0000) != 0
      let result = (a &<< 1) | (fcarry ? 0x01 : 0)
      cpu.fcarry = carry
      cpu.a = result
    }
  }
}
