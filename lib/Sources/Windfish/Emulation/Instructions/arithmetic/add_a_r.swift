import Foundation

extension LR35902.Emulation {
  final class add_a_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .add(.a, let register) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      let originalValue = cpu.a
      let registerValue = cpu[register] as UInt8
      let result = originalValue.addingReportingOverflow(registerValue)

      cpu.fzero = result.partialValue == 0
      cpu.fsubtract = false
      cpu.fcarry = result.overflow
      cpu.fhalfcarry = (((originalValue & 0x0f) + (registerValue & 0x0f)) & 0x10) > 0

      cpu.a = result.partialValue

      return .fetchNext
    }

    private let register: LR35902.Instruction.Numeric
  }
}
