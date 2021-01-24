import Foundation

extension LR35902.Emulation {
  final class ld_rraddr_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registersAddr = LR35902.Instruction.Numeric.registersAddr
      guard case .ld(let dst, .imm8) = spec, registersAddr.contains(dst) else {
        return nil
      }
      self.dst = dst
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      immediate = UInt8(memory.read(from: cpu.pc))
      cpu.pc += 1
      memory.write(immediate, to: cpu[dst])
    }

    private let dst: LR35902.Instruction.Numeric
    private var immediate: UInt8 = 0
  }
}
