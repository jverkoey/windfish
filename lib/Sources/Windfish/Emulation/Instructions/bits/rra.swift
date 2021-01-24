import Foundation

extension LR35902.Emulation {
  final class rra: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .rra = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      cpu.fzero = false
      cpu.fsubtract = false
      cpu.fhalfcarry = false

      let carry = (cpu.a & 0x01) != 0
      cpu.a = (cpu.a &>> 1) | (cpu.fcarry ? 0b1000_0000 : 0)
      cpu.fcarry = carry
    }
  }
}
