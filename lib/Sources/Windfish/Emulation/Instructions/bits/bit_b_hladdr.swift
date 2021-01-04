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
      bit(cpu: cpu, bit: bit, value: value)
      return .fetchNext
    }

    private let bit: LR35902.Instruction.Bit
    private var value: UInt8 = 0
  }
}
