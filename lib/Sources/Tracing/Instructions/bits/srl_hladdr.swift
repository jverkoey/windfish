import Foundation

import LR35902

extension LR35902.Emulation {
  final class srl_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.srl(.hladdr)) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      // No trace needed.

      cpu.fsubtract = false
      cpu.fhalfcarry = false

      guard let hl: UInt16 = cpu.hl,
            let value: UInt8 = memory.read(from: hl) else {
        if let hl: UInt16 = cpu.hl {
          memory.write(nil, to: hl)
        }
        cpu.fzero = nil
        cpu.fcarry = nil
        return
      }

      let carry = (value & 1) != 0
      let result = value &>> 1
      cpu.fzero = result == 0
      cpu.fcarry = carry
      memory.write(result, to: hl)
    }
  }
}
