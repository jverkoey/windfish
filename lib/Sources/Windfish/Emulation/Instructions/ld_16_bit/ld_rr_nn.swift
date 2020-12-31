import Foundation

extension LR35902.Emulation {
  final class ld_rr_nn: InstructionEmulator {
    init?(spec: LR35902.Instruction.Spec) {
      let registers16 = LR35902.Instruction.Numeric.registers16
      guard case .ld(let dst, .imm16) = spec, registers16.contains(dst) else {
        return nil
      }
      self.dst = dst
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

      cpu[dst] = immediate
      cpu.registerTraces[dst] = .init(
        sourceLocation: sourceLocation,
        loadAddress: immediate
      )
      return .fetchNext
    }

    private let dst: LR35902.Instruction.Numeric
    private var immediate: UInt16 = 0
  }
}
