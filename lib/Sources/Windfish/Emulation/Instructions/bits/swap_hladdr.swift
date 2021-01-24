import Foundation

extension LR35902.Emulation {
  final class swap_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.swap(.hladdr)) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      value = memory.read(from: cpu.hl)
      cpu.fsubtract = false
      cpu.fcarry = false
      cpu.fhalfcarry = false

      let upperNibble: UInt8 = value & 0xF0
      let lowerNibble: UInt8 = value & 0x0F

      let result = (upperNibble >> 4) | (lowerNibble << 4)
      value = result
      cpu.fzero = result == 0
      memory.write(value, to: cpu.hl)
    }

    private var value: UInt8 = 0
  }
}
