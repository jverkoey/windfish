import Foundation

extension LR35902.Emulation {
  final class daa: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .daa = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      var result: UInt16 = UInt16(truncatingIfNeeded: cpu.a)
      if cpu.fsubtract {
        if cpu.fhalfcarry {
          result = (result &- 6) & 0xff
        }
        if cpu.fcarry {
          result &-= 0x60
        }
      } else {
        if cpu.fhalfcarry || (result & 0xf) > 9 {
          result &+= 6
        }
        if cpu.fcarry || result > 0x9f {
          result &+= 0x60
        }
      }
      cpu.fhalfcarry = false
      if (result & 0x100) != 0 {
        cpu.fcarry = true
      }
      cpu.a = UInt8(truncatingIfNeeded: result & 0xff)
      cpu.fzero = cpu.a == 0
    }
  }
}
