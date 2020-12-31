import Foundation

extension LR35902.Emulation {
  final class bit_b_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .cb(.bit(let bit, let register)) = spec, registers8.contains(register) else {
        return nil
      }
      self.bit = bit
      self.register = register
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      cpu.fzero = (cpu[register] & (UInt8(1) << bit.rawValue)) == 0
      cpu.fsubtract = false
      cpu.fhalfcarry = true
      return .fetchNext
    }

    private let register: LR35902.Instruction.Numeric
    private let bit: LR35902.Instruction.Bit
  }
}
