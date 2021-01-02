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
      let value = cpu[register] as UInt8
      let carry = (value & 0b1000_0000) != 0
      let result =  value &<< 1
      cpu[register] = result
      cpu.fzero = result == 0
      cpu.fsubtract = false
      cpu.fcarry = carry
      cpu.fhalfcarry = false
      return .fetchNext
    }

    private let register: LR35902.Instruction.Numeric
  }
}
