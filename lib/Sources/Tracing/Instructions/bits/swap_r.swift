import Foundation

import LR35902

extension LR35902.Emulation {
  final class swap_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .cb(.swap(let register)) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      cpu.fsubtract = false
      cpu.fcarry = false
      cpu.fhalfcarry = false

      guard let value: UInt8 = cpu[register] else {
        cpu.fzero = nil
        return
      }
      let upperNibble: UInt8 = value & 0xF0
      let lowerNibble: UInt8 = value & 0x0F

      let result = (upperNibble >> 4) | (lowerNibble << 4)
      cpu[register] = result
      cpu.fzero = result == 0
    }

    private let register: LR35902.Instruction.Numeric
  }
}
