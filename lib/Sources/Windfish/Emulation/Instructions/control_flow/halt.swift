import Foundation

extension LR35902.Emulation {
  final class halt: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .halt = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      // TODO: Implement HALT bug behavior outlined in https://github.com/AntonioND/giibiiadvance/tree/master/docs
      cpu.halted = true
    }
  }
}
