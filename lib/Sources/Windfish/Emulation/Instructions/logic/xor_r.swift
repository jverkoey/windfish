import Foundation

extension LR35902.Emulation {
  final class xor_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .xor(let register) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      cpu.a ^= cpu[register]
      cpu.fzero = cpu.a == 0
      cpu.fsubtract = false
      cpu.fcarry = false
      cpu.fhalfcarry = false
      return .fetchNext
    }

    private let register: LR35902.Instruction.Numeric
  }
}
