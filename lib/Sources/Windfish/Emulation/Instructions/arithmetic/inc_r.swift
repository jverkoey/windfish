import Foundation

extension LR35902.Emulation {
  final class inc_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .inc(let register) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      let originalValue = cpu[register] as UInt8
      let result = originalValue.addingReportingOverflow(1)
      cpu.fzero = result.partialValue == 0
      cpu.fhalfcarry = (((originalValue & 0x0f) + 1) & 0x10) > 0
      cpu.fsubtract = false
      cpu[register] = result.partialValue
      return .fetchNext
    }

    private let register: LR35902.Instruction.Numeric
  }
}
