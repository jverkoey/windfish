import Foundation

extension LR35902.Emulation {
  final class cp_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cp(.hladdr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      value = memory.read(from: cpu.hl)
      cp(cpu: cpu, value: value)
    }

    private var value: UInt8 = 0
  }
}
