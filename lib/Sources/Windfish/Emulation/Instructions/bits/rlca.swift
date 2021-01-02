import Foundation

extension LR35902.Emulation {
  final class rlca: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .rlca = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      cpu.fzero = false
      cpu.fsubtract = false
      cpu.fhalfcarry = false

      let carry = (cpu.a & 0b1000_0000) != 0
      let result = (cpu.a &<< 1) | (carry ? 0x01 : 0)
      cpu.fcarry = carry
      cpu.a = result
      return .fetchNext
    }
  }
}
