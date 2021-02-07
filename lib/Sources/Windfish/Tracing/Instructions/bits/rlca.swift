import Foundation

import LR35902

extension LR35902.Emulation {
  final class rlca: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .rlca = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      cpu.fzero = false
      cpu.fsubtract = false
      cpu.fhalfcarry = false

      guard let a: UInt8 = cpu.a else {
        cpu.fcarry = nil
        return
      }
      let carry = (a & 0b1000_0000) != 0
      let result = (a &<< 1) | (carry ? 0x01 : 0)
      cpu.fcarry = carry
      cpu.a = result
    }
  }
}
