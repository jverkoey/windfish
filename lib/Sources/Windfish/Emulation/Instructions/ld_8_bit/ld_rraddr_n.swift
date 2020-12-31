import Foundation

extension LR35902.Emulation {
  final class ld_rraddr_n: InstructionEmulator {
    init?(spec: LR35902.Instruction.Spec) {
      let registersAddr = LR35902.Instruction.Numeric.registersAddr
      guard case .ld(let dst, .imm8) = spec, registersAddr.contains(dst) else {
        return nil
      }
      self.dst = dst
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult {
      if cycle == 1 {
        immediate = UInt8(memory.read(from: cpu.pc))
        cpu.pc += 1
        return .continueExecution
      }
      if cycle == 2 {
        memory.write(immediate, to: cpu[dst])
        return .continueExecution
      }
      return .fetchNext
    }

    private let dst: LR35902.Instruction.Numeric
    private var immediate: UInt8 = 0
  }
}
