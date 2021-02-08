import Foundation

import LR35902

extension LR35902.Emulation {
  final class rlc_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.rlc(.hladdr)) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      // No trace needed.

      cpu.fsubtract = false
      cpu.fhalfcarry = false

      guard let hl = cpu.hl,
            let value: UInt8 = memory.read(from: hl) else {
        if let hl = cpu.hl {
          memory.write(nil, to: hl)
        }
        cpu.hl = nil
        cpu.fzero = nil
        cpu.fcarry = nil
        return
      }
      let carry = (value & 0b1000_0000) != 0
      let result = (value &<< 1) | (carry ? 1 : 0)
      cpu.fzero = result == 0
      cpu.fcarry = carry
      memory.write(result, to: hl)
    }
  }
}
