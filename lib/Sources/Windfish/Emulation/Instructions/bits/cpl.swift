import Foundation

extension LR35902.Emulation {
  final class cpl: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cpl = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      cpu.a = ~cpu.a
      cpu.fsubtract = true
      cpu.fcarry = true
      return .fetchNext
    }
  }
}
