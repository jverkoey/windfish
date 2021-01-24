import Foundation

extension LR35902.Emulation {
  final class jp_hl: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .jp(nil, .hl) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      cpu.pc = cpu.hl
    }

    private var immediate: UInt16 = 0
  }
}
