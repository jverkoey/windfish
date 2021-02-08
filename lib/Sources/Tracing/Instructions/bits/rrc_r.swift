import Foundation

import LR35902

extension LR35902.Emulation {
  final class rrc_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .cb(.rrc(let register)) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      // No trace needed.

      cpu.fsubtract = false
      cpu.fhalfcarry = false

      guard let value: UInt8 = cpu[register] else {
        cpu.fzero = nil
        cpu.fcarry = nil
        return
      }
      let carry = (value & 0x01) != 0
      let result = (value &>> 1) | (carry ? 0b1000_0000 : 0)
      cpu.fzero = result == 0
      cpu.fcarry = carry
      cpu[register] = result
    }

    private let register: LR35902.Instruction.Numeric
  }
}
