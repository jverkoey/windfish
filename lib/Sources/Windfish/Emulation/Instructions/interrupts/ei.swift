import Foundation

extension LR35902.Emulation {
  final class ei: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ei = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      // IME will be enabled after the next machine cycle, so we set up a counter to track that delay.
      cpu.imeScheduledCyclesRemaining = 2
      return .fetchNext
    }
  }
}
