import Foundation

extension LR35902.Emulation {
  final class swap_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.swap(.hladdr)) = spec else {
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
        cpu.fcarry = false
        cpu.fhalfcarry = false

        let upperNibble: UInt8 = value & 0xF0
        let lowerNibble: UInt8 = value & 0x0F

        let result = (upperNibble >> 4) | (lowerNibble << 4)
        value = result
        cpu.fzero = result == 0
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
