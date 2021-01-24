import Foundation

extension LR35902.Emulation {
  final class rlc_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .cb(.rlc(let register)) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      cpu.fsubtract = false
      cpu.fhalfcarry = false

      let value = (cpu[register] as UInt8)
      let carry = (value & 0b1000_0000) != 0
      let result = (value &<< 1) | (carry ? 1 : 0)
      cpu.fzero = result == 0
      cpu.fcarry = carry
      cpu[register] = result
    }

    private let register: LR35902.Instruction.Numeric
  }
}
