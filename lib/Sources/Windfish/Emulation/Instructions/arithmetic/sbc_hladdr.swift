import Foundation

extension LR35902.Emulation {
  final class sbc_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .sbc(.hladdr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      value = memory.read(from: cpu.hl)
      if cpu.fcarry {
        carrysub(cpu: cpu, value: value)
      } else {
        sub(cpu: cpu, value: value)
      }
    }

    private var value: UInt8 = 0
  }
}
