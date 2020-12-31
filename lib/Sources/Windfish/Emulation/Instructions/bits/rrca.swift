import Foundation

extension LR35902.Emulation {
  final class rrca: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .rrca = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      let partialResult = cpu.a.dividedReportingOverflow(by: 2)
      let result = partialResult.partialValue | (partialResult.overflow ? 0b1000_0000 : 0)
      cpu.a = result
      cpu.fzero = result == 0
      cpu.fsubtract = false
      cpu.fcarry = partialResult.overflow
      cpu.fhalfcarry = false
      return .fetchNext
    }
  }
}
