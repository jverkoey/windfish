import Foundation

extension LR35902.Emulation {
  final class rlca: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .rlca = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      cpu.fzero = false
      cpu.fsubtract = false
      cpu.fhalfcarry = false

      let partialResult = cpu.a.multipliedReportingOverflow(by: 2)
      let result = partialResult.partialValue | (partialResult.overflow ? 0x01 : 0)
      cpu.fcarry = partialResult.overflow
      cpu.a = result
      return .fetchNext
    }
  }
}
