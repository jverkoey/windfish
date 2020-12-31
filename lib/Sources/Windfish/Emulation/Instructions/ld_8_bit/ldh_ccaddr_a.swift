import Foundation

extension LR35902.Emulation {
  final class ldh_ccaddr_a: InstructionEmulator {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.ffccaddr, .a) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult {
      if cycle == 1 {
        let address = UInt16(0xFF00) | UInt16(truncatingIfNeeded: cpu.c)
        memory.write(cpu.a, to: address)
        return .continueExecution
      }
      return .fetchNext
    }
  }
}
