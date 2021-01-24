import Foundation

extension LR35902.Emulation {
  final class add_a_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .add(.a, .hladdr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      value = memory.read(from: cpu.hl)
      add(cpu: cpu, value: value)
    }

    private var value: UInt8 = 0
  }
}
