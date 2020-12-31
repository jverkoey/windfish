import Foundation

extension LR35902.Emulation {
  final class call_cnd_nn: InstructionEmulator {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .call(let cnd, .imm16) = spec else {
        return nil
      }
      self.cnd = cnd
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult {
      if cycle == 1 {
        immediate = UInt16(truncatingIfNeeded: memory.read(from: cpu.pc))
        cpu.pc += 1
        return .continueExecution
      }
      if cycle == 2 {
        immediate |= UInt16(truncatingIfNeeded: memory.read(from: cpu.pc)) << 8
        cpu.pc += 1
        return .continueExecution
      }
      if cycle == 3 {
        return checkConditional(cnd: cnd, cpu: cpu)
      }
      if cycle == 4 {
        cpu.sp -= 1
        memory.write(UInt8(truncatingIfNeeded: (cpu.pc & 0xFF00) >> 8), to: cpu.sp)
        return .continueExecution
      }
      if cycle == 5 {
        cpu.sp -= 1
        memory.write(UInt8(truncatingIfNeeded: cpu.pc & 0x00FF), to: cpu.sp)
        return .continueExecution
      }
      cpu.pc = immediate
      return .fetchNext
    }

    private let cnd: LR35902.Instruction.Condition?
    private var immediate: UInt16 = 0
  }
}
