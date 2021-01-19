import Foundation

extension LR35902.Emulation {
  final class ei: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ei = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Gameboy.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if !cpu.ime && cpu.imeToggleDelay == 0 {
        // ei requires we wait one full machine cycle before turning on ime. We use a countdown from 2 to skip the
        // machine cycle that initiated the ei.
        cpu.imeToggleDelay = 2
      }
      return .fetchNext
    }
  }
}
