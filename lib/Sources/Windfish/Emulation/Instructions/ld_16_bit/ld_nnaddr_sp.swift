import Foundation

extension LR35902.Emulation {
  final class ld_nnaddr_sp: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.imm16addr, .sp) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      immediate = UInt16(truncatingIfNeeded: memory.read(from: cpu.pc))
      cpu.pc += 1
      immediate |= UInt16(truncatingIfNeeded: memory.read(from: cpu.pc)) << 8
      cpu.pc += 1
      memory.write(UInt8(truncatingIfNeeded: cpu.sp & 0x00FF), to: immediate)
      memory.write(UInt8(truncatingIfNeeded: (cpu.sp & 0xFF00) >> 8), to: immediate + 1)
    }

    private var immediate: UInt16 = 0
  }
}
