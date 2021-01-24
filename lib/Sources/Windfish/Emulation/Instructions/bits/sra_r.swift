import Foundation

extension LR35902.Emulation {
  final class sra_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .cb(.sra(let register)) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      sra(cpu: cpu, value: &cpu[register])
    }

    private let register: LR35902.Instruction.Numeric
  }
}
