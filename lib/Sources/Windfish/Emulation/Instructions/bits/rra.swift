import Foundation

extension LR35902.Emulation {
  final class rra: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .rra = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      let partialResult = cpu.a.dividedReportingOverflow(by: 2)
      let result = partialResult.partialValue | (cpu.fcarry ? 0b1000_0000 : 0)
      cpu.a = result
      cpu.fzero = result == 0
      cpu.fsubtract = false
      cpu.fcarry = partialResult.overflow
      cpu.fhalfcarry = false
      return .fetchNext
    }
  }
}
