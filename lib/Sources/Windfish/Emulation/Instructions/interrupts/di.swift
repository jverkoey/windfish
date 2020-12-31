import Foundation

extension LR35902.Emulation {
  final class di: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .di = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      cpu.ime = false
      cpu.imeScheduledCyclesRemaining = 0
      return .fetchNext
    }
  }
}
