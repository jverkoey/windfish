import Foundation

extension LR35902.Emulation {
  final class dec_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .dec(let register) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      let originalValue = cpu[register] as UInt8
      let result = originalValue.subtractingReportingOverflow(1)
      cpu.fzero = result.partialValue == 0
      cpu.fsubtract = true
      cpu.fhalfcarry = (originalValue & 0x0f) < (1 & 0x0f)
      cpu[register] = result.partialValue
      return .fetchNext
    }

    private let register: LR35902.Instruction.Numeric
  }
}
