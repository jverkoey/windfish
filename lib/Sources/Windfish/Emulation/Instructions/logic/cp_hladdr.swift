import Foundation

extension LR35902.Emulation {
  final class cp_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cp(.hladdr) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        value = memory.read(from: cpu.hl)
        return .continueExecution
      }
      cpu.fsubtract = true
      let result = cpu.a.subtractingReportingOverflow(value)
      cpu.fzero = result.partialValue == 0
      cpu.fcarry = result.overflow
      cpu.fhalfcarry = (cpu.a & 0x0f) < (value & 0x0f)
      return .fetchNext
    }

    private var value: UInt8 = 0
  }
}
