import Foundation

import LR35902

extension LR35902.Emulation {
  final class daa: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .daa = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      defer {
        cpu.fhalfcarry = false
      }

      guard let a = cpu.a,
            let fsubtract = cpu.fsubtract,
            let fhalfcarry = cpu.fhalfcarry,
            let fcarry = cpu.fcarry else {
        cpu.a = nil
        cpu.fcarry = nil
        cpu.fzero = nil
        return
      }

      var result: UInt16 = UInt16(truncatingIfNeeded: a)
      if fsubtract {
        if fhalfcarry {
          result = (result &- 6) & 0xff
        }
        if fcarry {
          result &-= 0x60
        }
      } else {
        if fhalfcarry || (result & 0xf) > 9 {
          result &+= 6
        }
        if fcarry || result > 0x9f {
          result &+= 0x60
        }
      }
      if (result & 0x100) != 0 {
        cpu.fcarry = true
      }
      cpu.a = UInt8(truncatingIfNeeded: result & 0xff)
      cpu.fzero = cpu.a == 0
    }
  }
}
