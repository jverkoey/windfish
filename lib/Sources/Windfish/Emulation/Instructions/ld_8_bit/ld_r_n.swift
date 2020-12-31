import Foundation

extension LR35902.Emulation {
  final class ld_r_n: InstructionEmulator {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .ld(let dst, .imm8) = spec, registers8.contains(dst) else {
        return nil
      }
      self.dst = dst
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult {
      if cycle == 1 {
        immediate = memory.read(from: cpu.pc)
        cpu.pc += 1
        return .continueExecution
      }
      cpu[dst] = immediate
      cpu.registerTraces[dst] = .init(sourceLocation: sourceLocation)
      return .fetchNext
    }

    private let dst: LR35902.Instruction.Numeric
    private var immediate: UInt8 = 0
  }
}
