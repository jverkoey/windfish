import Foundation

extension LR35902.Emulation {
  final class ldd_hladdr_a: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ldd(.hladdr, .a) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      memory.write(cpu.a, to: cpu.hl)
      cpu.hl -= 1
    }
  }
}
