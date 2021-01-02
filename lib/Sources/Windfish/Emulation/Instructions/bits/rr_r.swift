import Foundation

extension LR35902.Emulation {
  final class rr_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .cb(.rr(let register)) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      cpu.fsubtract = false
      cpu.fhalfcarry = false

      let carry = ((cpu[register] as UInt8) & 0b0000_0001) != 0
      let result = ((cpu[register] as UInt8) &>> 1) | (cpu.fcarry ? 0b1000_0000 : 0)
      cpu[register] = result
      cpu.fzero = result == 0
      cpu.fcarry = carry
      return .fetchNext
    }

    private let register: LR35902.Instruction.Numeric
  }
}
