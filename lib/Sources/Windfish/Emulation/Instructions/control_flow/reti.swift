import Foundation

extension LR35902.Emulation {
  final class reti: InstructionEmulator {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .reti = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult {
      if cycle == 1 {
        pc = UInt16(truncatingIfNeeded: memory.read(from: cpu.sp))
        cpu.sp += 1
        return .continueExecution
      }
      if cycle == 2 {
        pc |= UInt16(truncatingIfNeeded: memory.read(from: cpu.sp)) << 8
        cpu.sp += 1
        return .continueExecution
      }
      if cycle == 3 {
        cpu.ime = true
        return .continueExecution
      }
      cpu.pc = pc
      return .fetchNext
    }

    private var pc: UInt16 = 0
  }
}
