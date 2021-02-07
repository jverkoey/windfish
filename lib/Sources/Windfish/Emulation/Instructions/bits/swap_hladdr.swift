import Foundation

import LR35902

extension LR35902.Emulation {
  final class swap_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.swap(.hladdr)) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      cpu.fsubtract = false
      cpu.fcarry = false
      cpu.fhalfcarry = false

      guard let hl: UInt16 = cpu.hl,
            let value: UInt8 = memory.read(from: hl) else {
        if let hl: UInt16 = cpu.hl {
          memory.write(nil, to: hl)
        }
        cpu.fzero = nil
        return
      }

      let upperNibble: UInt8 = value & 0xF0
      let lowerNibble: UInt8 = value & 0x0F

      let result = (upperNibble >> 4) | (lowerNibble << 4)
      cpu.fzero = result == 0
      memory.write(result, to: hl)
    }
  }
}
