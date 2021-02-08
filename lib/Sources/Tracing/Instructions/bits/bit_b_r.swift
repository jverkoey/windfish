import Foundation

import LR35902

extension LR35902.Emulation {
  final class bit_b_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .cb(.bit(let bit, let register)) = spec, registers8.contains(register) else {
        return nil
      }
      self.bit = bit
      self.register = register
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      cpu.fsubtract = false
      cpu.fhalfcarry = true
      guard let value: UInt8 = cpu[register] else {
        cpu.fzero = nil
        return
      }
      cpu.fzero = (value & (UInt8(1) << bit.rawValue)) == 0
    }

    private let register: LR35902.Instruction.Numeric
    private let bit: LR35902.Instruction.Bit
  }
}
