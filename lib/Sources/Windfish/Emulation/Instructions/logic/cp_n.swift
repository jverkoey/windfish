import Foundation

extension LR35902.Emulation {
  final class cp_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cp(.imm8) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      immediate = memory.read(from: cpu.pc)
      cpu.pc += 1
      cp(cpu: cpu, value: immediate)
    }

    private var immediate: UInt8 = 0
  }
}
