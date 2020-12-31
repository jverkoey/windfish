import Foundation

extension LR35902.Emulation {
  final class add_a_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .add(.a, .hladdr) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        value = memory.read(from: cpu.hl)
        return .continueExecution
      }
      let originalValue = cpu.a
      let result = originalValue.addingReportingOverflow(value)
      cpu.fzero = result.partialValue == 0
      cpu.fsubtract = false
      cpu.fcarry = result.overflow
      cpu.fhalfcarry = (((originalValue & 0x0f) + (value & 0x0f)) & 0x10) > 0
      cpu.a = result.partialValue
      return .fetchNext
    }

    private var value: UInt8 = 0
  }
}
