import Foundation

extension LR35902.Emulation {
  final class xor_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .xor(.imm8) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      immediate = UInt8(memory.read(from: cpu.pc))
      cpu.pc += 1
      cpu.a ^= immediate
      cpu.fzero = cpu.a == 0
      cpu.fsubtract = false
      cpu.fcarry = false
      cpu.fhalfcarry = false
    }

    private var immediate: UInt8 = 0
  }
}
