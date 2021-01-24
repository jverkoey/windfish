import Foundation

extension LR35902.Emulation {
  final class sub_a_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .sub(.a, .imm8) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      immediate = UInt8(memory.read(from: cpu.pc))
      cpu.pc += 1
      sub(cpu: cpu, value: immediate)
    }

    private var immediate: UInt8 = 0
  }
}
