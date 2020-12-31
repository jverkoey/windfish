import Foundation

extension LR35902.Emulation {
  final class rlca: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .rlca = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      let partialResult = cpu.a.multipliedReportingOverflow(by: 2)
      let result = partialResult.partialValue | (partialResult.overflow ? 0x01 : 0)

      cpu.fzero = result == 0
      cpu.fsubtract = false
      cpu.fcarry = partialResult.overflow
      cpu.fhalfcarry = false

      cpu.a = result

      return .fetchNext
    }
  }
}
