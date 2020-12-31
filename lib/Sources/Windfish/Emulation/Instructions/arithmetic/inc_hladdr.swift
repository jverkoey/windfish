import Foundation

extension LR35902.Emulation {
  final class inc_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .inc(.hladdr) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        value = memory.read(from: cpu.hl)
        return .continueExecution
      }
      if cycle == 2 {
        let result = value.addingReportingOverflow(1)
        cpu.fzero = result.partialValue == 0
        cpu.fhalfcarry = (((value & 0x0f) + 1) & 0x10) > 0
        cpu.fsubtract = false
        value = result.partialValue
        return .continueExecution
      }
      if cycle == 3 {
        memory.write(value, to: cpu.hl)
        return .continueExecution
      }
      return .fetchNext
    }

    private var value: UInt8 = 0
  }
}
