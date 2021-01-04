import Foundation

extension LR35902.Emulation {
  final class dec_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .dec(.hladdr) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        value = memory.read(from: cpu.hl)
        return .continueExecution
      }
      if cycle == 2 {
        cpu.fsubtract = true
        // fcarry not affected
        value &-= 1
        cpu.fzero = value == 0
        cpu.fhalfcarry = (value & 0xf) == 0xf
        memory.write(value, to: cpu.hl)
        return .continueExecution
      }
      return .fetchNext
    }

    private var value: UInt8 = 0
  }
}
