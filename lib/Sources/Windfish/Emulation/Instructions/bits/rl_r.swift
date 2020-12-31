import Foundation

extension LR35902.Emulation {
  final class rl_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .cb(.rl(let register)) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      let partialResult = (cpu[register] as UInt8).multipliedReportingOverflow(by: 2)
      let result = partialResult.partialValue | (partialResult.overflow ? 0x01 : 0)

      cpu.fzero = result == 0
      cpu.fsubtract = false
      cpu.fcarry = partialResult.overflow
      cpu.fhalfcarry = false

      cpu[register] = result

      return .fetchNext
    }

    private let register: LR35902.Instruction.Numeric
  }
}
