import Foundation

extension LR35902.Emulation {
  final class adc_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .adc(.imm8) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      immediate = memory.read(from: cpu.pc)
      cpu.pc += 1
      if cpu.fcarry {
        carryadd(cpu: cpu, value: immediate)
      } else {
        add(cpu: cpu, value: immediate)
      }
    }

    private var immediate: UInt8 = 0
  }
}
