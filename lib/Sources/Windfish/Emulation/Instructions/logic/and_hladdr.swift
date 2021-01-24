import Foundation

extension LR35902.Emulation {
  final class and_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .and(.hladdr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      value = memory.read(from: cpu.hl)
      cpu.a &= value
      cpu.fzero = cpu.a == 0
      cpu.fsubtract = false
      cpu.fcarry = false
      cpu.fhalfcarry = true
    }

    private var value: UInt8 = 0
  }
}
