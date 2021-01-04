import Foundation

extension LR35902.Emulation {
  final class sra_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.sra(.hladdr)) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        value = memory.read(from: cpu.hl)
        return .continueExecution
      }
      if cycle == 2 {
        sra(cpu: cpu, value: &value)
        memory.write(value, to: cpu.hl)
        return .continueExecution
      }
      return .fetchNext
    }

    private var value: UInt8 = 0
  }
}
