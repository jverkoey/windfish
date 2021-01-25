import Foundation

extension LR35902.Emulation {
  final class rl_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .cb(.rl(let register)) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      cpu.fsubtract = false
      cpu.fhalfcarry = false

      guard let value: UInt8 = cpu[register],
            let fcarry: Bool = cpu.fcarry else {
        cpu.set(numeric8: register, to: nil)
        cpu.fzero = nil
        cpu.fcarry = nil
        return
      }

      let carry = (value & 0b1000_0000) != 0
      let result = (value &<< 1) | (fcarry ? 1 : 0)
      cpu[register] = result
      cpu.fzero = result == 0
      cpu.fcarry = carry
    }

    private let register: LR35902.Instruction.Numeric
  }
}
