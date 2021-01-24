import Foundation

extension LR35902.Emulation {
  final class dec_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .dec(.hladdr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      value = memory.read(from: cpu.hl)
      cpu.fsubtract = true
      // fcarry not affected
      value &-= 1
      cpu.fzero = value == 0
      cpu.fhalfcarry = (value & 0xf) == 0xf
      memory.write(value, to: cpu.hl)
    }

    private var value: UInt8 = 0
  }
}
