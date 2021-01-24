import Foundation

extension LR35902.Emulation {
  final class ld_nnaddr_a: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.imm16addr, .a) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      immediate = UInt16(truncatingIfNeeded: memory.read(from: cpu.pc))
      cpu.pc += 1
      immediate |= UInt16(truncatingIfNeeded: memory.read(from: cpu.pc)) << 8
      cpu.pc += 1
      memory.write(cpu.a, to: immediate)
    }

    private var immediate: UInt16 = 0
  }
}
