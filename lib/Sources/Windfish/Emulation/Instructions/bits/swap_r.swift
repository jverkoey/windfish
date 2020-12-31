import Foundation

extension LR35902.Emulation {
  final class swap_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .cb(.swap(let register)) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      let upperNibble: UInt8 = cpu[register] & 0xF0
      let lowerNibble: UInt8 = cpu[register] & 0x0F
      let result = (upperNibble >> 8) | (lowerNibble << 8)
      cpu[register] = result
      cpu.fzero = result == 0
      cpu.fsubtract = false
      cpu.fcarry = false
      cpu.fhalfcarry = false
      return .fetchNext
    }

    private let register: LR35902.Instruction.Numeric
  }
}
