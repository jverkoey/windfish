import Foundation

extension LR35902.Emulation {
  final class ldi_hladdr_a: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ldi(.hladdr, .a) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Gameboy.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        memory.write(cpu.a, to: cpu.hl)
        return .continueExecution
      }
      cpu.hl &+= 1
      return .fetchNext
    }
  }
}
