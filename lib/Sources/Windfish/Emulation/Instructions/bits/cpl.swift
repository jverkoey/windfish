import Foundation

extension LR35902.Emulation {
  final class cpl: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cpl = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      cpu.a = ~cpu.a
      cpu.fsubtract = true
      cpu.fhalfcarry = true
    }
  }
}
