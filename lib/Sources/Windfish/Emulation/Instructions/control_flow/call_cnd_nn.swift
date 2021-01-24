import Foundation

extension LR35902.Emulation {
  final class call_cnd_nn: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .call(let cnd, .imm16) = spec else {
        return nil
      }
      self.cnd = cnd
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      immediate = UInt16(truncatingIfNeeded: memory.read(from: cpu.pc))
      cpu.pc += 1
      immediate |= UInt16(truncatingIfNeeded: memory.read(from: cpu.pc)) << 8
      cpu.pc += 1
      if passesCondition(cnd: cnd, cpu: cpu) {
        cpu.sp &-= 1
        memory.write(UInt8(truncatingIfNeeded: (cpu.pc & 0xFF00) >> 8), to: cpu.sp)
        cpu.sp &-= 1
        memory.write(UInt8(truncatingIfNeeded: cpu.pc & 0x00FF), to: cpu.sp)
        cpu.pc = immediate
      }
    }

    private let cnd: LR35902.Instruction.Condition?
    private var immediate: UInt16 = 0
  }
}
