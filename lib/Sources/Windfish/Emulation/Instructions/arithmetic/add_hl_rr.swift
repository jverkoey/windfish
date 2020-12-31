import Foundation

extension LR35902.Emulation {
  final class add_hl_rr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers16 = LR35902.Instruction.Numeric.registers16
      guard case .add(.hl, let src) = spec, registers16.contains(src) else {
        return nil
      }
      self.src = src
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        return .continueExecution
      }
      let originalValue = cpu.hl
      let sourceValue: UInt16 = cpu[src]
      let result = originalValue.addingReportingOverflow(sourceValue)
      cpu.fsubtract = false
      cpu.fcarry = result.overflow
      cpu.fhalfcarry = (((originalValue & 0x0fff) + (sourceValue & 0x0fff)) & 0x1000) > 0
      cpu.hl = result.partialValue
      return .fetchNext
    }

    private let src: LR35902.Instruction.Numeric
  }
}
