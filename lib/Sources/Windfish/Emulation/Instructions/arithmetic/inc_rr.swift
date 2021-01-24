import Foundation

extension LR35902.Emulation {
  final class inc_rr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers16 = LR35902.Instruction.Numeric.registers16
      guard case .inc(let register) = spec, registers16.contains(register) else {
        return nil
      }
      self.register = register
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      cpu[register] = (cpu[register] as UInt16) &+ 1
    }

    private let register: LR35902.Instruction.Numeric
  }
}
