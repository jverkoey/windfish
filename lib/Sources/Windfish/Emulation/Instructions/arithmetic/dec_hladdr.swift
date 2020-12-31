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
        let result = value.subtractingReportingOverflow(1)
        cpu.fzero = result.partialValue == 0
        cpu.fsubtract = true
        cpu.fhalfcarry = (value & 0x0f) < (1 & 0x0f)

        value = result.partialValue

        return .continueExecution
      }
      memory.write(value, to: cpu.hl)
      return .fetchNext
    }

    private var value: UInt8 = 0
  }
}
