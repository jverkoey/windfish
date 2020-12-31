import Foundation

extension LR35902.Emulation {
  final class sub_a_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .sub(.a, .hladdr) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        value = memory.read(from: cpu.hl)
        return .continueExecution
      }
      let originalValue = cpu.a
      let result = originalValue.subtractingReportingOverflow(value)
      cpu.fzero = result.partialValue == 0
      cpu.fsubtract = true
      cpu.fcarry = result.overflow
      cpu.fhalfcarry = (cpu.a & 0x0f) < (value & 0x0f)
      cpu.a = result.partialValue
      return .fetchNext
    }

    private var value: UInt8 = 0
  }
}
