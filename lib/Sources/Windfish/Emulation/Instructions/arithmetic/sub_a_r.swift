import Foundation

extension LR35902.Emulation {
  final class sub_a_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .sub(.a, let register) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      let originalValue = cpu.a
      let value = cpu[register] as UInt8
      let result = originalValue.subtractingReportingOverflow(value)
      cpu.fzero = result.partialValue == 0
      cpu.fsubtract = true
      cpu.fcarry = result.overflow
      cpu.fhalfcarry = (cpu.a & 0x0f) < (value & 0x0f)
      cpu.a = result.partialValue
      return .fetchNext
    }

    private let register: LR35902.Instruction.Numeric
  }
}
