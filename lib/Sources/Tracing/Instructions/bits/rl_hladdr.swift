import Foundation

import LR35902

extension LR35902.Emulation {
  final class rl_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.rl(.hladdr)) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      // No trace needed.

      cpu.fsubtract = false
      cpu.fhalfcarry = false

      guard let hl: UInt16 = cpu.hl,
            let fcarry: Bool = cpu.fcarry,
            let value: UInt8 = memory.read(from: hl) else {
        cpu.fzero = nil
        cpu.fcarry = nil
        if let hl = cpu.hl {
          memory.write(nil, to: hl)
        }
        return
      }

      let carry = (value & 0b1000_0000) != 0
      let result = (value &<< 1) | (fcarry ? 1 : 0)
      cpu.fzero = result == 0
      cpu.fcarry = carry
      memory.write(result, to: hl)
    }
  }
}
