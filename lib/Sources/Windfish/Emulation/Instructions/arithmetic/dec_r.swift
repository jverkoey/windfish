import Foundation

extension LR35902.Emulation {
  final class dec_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .dec(let register) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      cpu.fsubtract = true

      guard let value: UInt8 = cpu[register] else {
        cpu.fzero = nil
        cpu.fhalfcarry = nil
        return
      }
      // fcarry not affected
      let result = value &- 1
      cpu[register] = result
      cpu.fzero = result == 0
      cpu.fhalfcarry = (result & 0xf) == 0xf
    }

    private let register: LR35902.Instruction.Numeric
  }
}
