import Foundation

extension LR35902.Emulation {
  final class adc_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .adc(.hladdr) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Gameboy.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        value = memory.read(from: cpu.hl)
        return .continueExecution
      }
      if cpu.fcarry {
        carryadd(cpu: cpu, value: value)
      } else {
        add(cpu: cpu, value: value)
      }
      return .fetchNext
    }

    private var value: UInt8 = 0
  }
}
