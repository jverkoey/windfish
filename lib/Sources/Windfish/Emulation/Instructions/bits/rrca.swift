import Foundation

extension LR35902.Emulation {
  final class rrca: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .rrca = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      cpu.fsubtract = false
      cpu.fhalfcarry = false
      cpu.fzero = false

      guard let a: UInt8 = cpu.a else {
        cpu.fcarry = nil
        return
      }
      let carry = (a & 0x01) != 0
      let result = (a &>> 1) | (carry ? 0b1000_0000 : 0)
      cpu.a = result
      cpu.fcarry = carry
    }
  }
}
