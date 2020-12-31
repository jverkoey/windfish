import Foundation

extension LR35902.Emulation {
  final class bit_b_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.bit(let bit, .hladdr)) = spec else {
        return nil
      }
      self.bit = bit
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        value = memory.read(from: cpu.hl)
        return .continueExecution
      }
      if cycle == 2 {
        cpu.fzero = (value & (UInt8(1) << bit.rawValue)) == 0
        cpu.fsubtract = false
        cpu.fhalfcarry = true
        return .continueExecution
      }
      if cycle == 3 {
        memory.write(value, to: cpu.hl)
        return .continueExecution
      }
      return .fetchNext
    }

    private let bit: LR35902.Instruction.Bit
    private var value: UInt8 = 0
  }
}
