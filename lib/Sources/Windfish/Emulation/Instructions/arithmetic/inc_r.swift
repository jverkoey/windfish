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
      cpu.fsubtract = false
      // fcarry not affected
      let result = (cpu[register] as UInt8) &+ 1
      cpu[register] = result
      cpu.fzero = result == 0
      cpu.fhalfcarry = (result & 0xF) == 0
      return .fetchNext
    }

    private let register: LR35902.Instruction.Numeric
  }
}
