import Foundation

extension LR35902.Emulation {
  final class ldd_hladdr_a: InstructionEmulator {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ldd(.hladdr, .a) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult {
      if cycle == 1 {
        memory.write(cpu.a, to: cpu.hl)
        return .continueExecution
      }
      cpu.hl -= 1
      return .fetchNext
    }
  }
}
