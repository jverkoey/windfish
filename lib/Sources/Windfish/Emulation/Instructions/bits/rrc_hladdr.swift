import Foundation

extension LR35902.Emulation {
  final class rrc_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.rrc(.hladdr)) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      value = memory.read(from: cpu.hl)
      rrc(cpu: cpu, value: &value)
      memory.write(value, to: cpu.hl)
    }

    private var value: UInt8 = 0
  }
}
