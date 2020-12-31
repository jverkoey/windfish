import Foundation

extension LR35902.Emulation {
  final class push_rr: InstructionEmulator {
    init?(spec: LR35902.Instruction.Spec) {
      let registers16 = LR35902.Instruction.Numeric.registers16
      guard case .push(let src) = spec, registers16.contains(src) else {
        return nil
      }
      self.src = src
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult {
      if cycle == 1 {
        cpu.sp -= 1
        return .continueExecution
      }
      if cycle == 2 {
        memory.write(UInt8(truncatingIfNeeded: ((cpu[src] as UInt16) & 0xFF00) >> 8), to: cpu.sp)
        cpu.sp -= 1
        return .continueExecution
      }
      if cycle == 3 {
        memory.write(UInt8(truncatingIfNeeded:(cpu[src] as UInt16) & 0x00FF), to: cpu.sp)
        return .continueExecution
      }
      return .fetchNext
    }

    private let src: LR35902.Instruction.Numeric
  }
}
