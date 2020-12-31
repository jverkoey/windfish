import Foundation

extension LR35902.Emulation {
  final class ldd_a_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ldd(.a, .hladdr) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        cpu.a = memory.read(from: cpu.hl)
        cpu.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: cpu.hl)
        return .continueExecution
      }
      cpu.hl -= 1
      return .fetchNext
    }
  }
}
