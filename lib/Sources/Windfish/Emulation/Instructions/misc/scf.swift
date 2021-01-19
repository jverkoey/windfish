import Foundation

extension LR35902.Emulation {
  final class scf: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .scf = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Gameboy.SourceLocation) -> LR35902.Emulation.EmulationResult {
      // cpu.fzero is not affected
      cpu.fsubtract = false
      cpu.fhalfcarry = false
      cpu.fcarry = true
      return .fetchNext
    }
  }
}
