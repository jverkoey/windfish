import Foundation

extension LR35902.Emulation {
  final class sla_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .cb(.sla(let register)) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      let result = (cpu[register] as UInt8).multipliedReportingOverflow(by: 2)
      cpu[register] = result.partialValue
      cpu.fzero = result.partialValue == 0
      cpu.fsubtract = false
      cpu.fcarry = result.overflow
      cpu.fhalfcarry = false
      return .fetchNext
    }

    private let register: LR35902.Instruction.Numeric
  }
}
