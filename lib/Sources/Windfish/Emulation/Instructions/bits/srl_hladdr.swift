import Foundation

extension LR35902.Emulation {
  final class srl_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.srl(.hladdr)) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        value = memory.read(from: cpu.hl)
        return .continueExecution
      }
      if cycle == 2 {
        cpu.fsubtract = false
        cpu.fhalfcarry = false

        let carry = (value & 1) != 0
        let result = value &>> 1
        cpu.fzero = result == 0
        cpu.fcarry = carry
        value = result
        return .continueExecution
      }
      if cycle == 3 {
        memory.write(value, to: cpu.hl)
        return .continueExecution
      }
      return .fetchNext
    }

    private var value: UInt8 = 0
  }
}
