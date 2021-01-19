import Foundation

extension LR35902.Emulation {
  final class dec_rr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers16 = LR35902.Instruction.Numeric.registers16
      guard case .dec(let register) = spec, registers16.contains(register) else {
        return nil
      }
      self.register = register
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Gameboy.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        return .continueExecution
      }
      cpu[register] = (cpu[register] as UInt16) &- 1
      return .fetchNext
    }

    private let register: LR35902.Instruction.Numeric
  }
}
