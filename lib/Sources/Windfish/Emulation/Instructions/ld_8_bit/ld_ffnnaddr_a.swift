import Foundation

extension LR35902.Emulation {
  final class ld_ffnnaddr_a: InstructionEmulator {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.ffimm8addr, .a) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult {
      if cycle == 1 {
        immediate = UInt16(truncatingIfNeeded: memory.read(from: cpu.pc))
        cpu.pc += 1
        return .continueExecution
      }
      if cycle == 2 {
        let address = UInt16(0xFF00) | immediate
        memory.write(cpu.a, to: address)
        return .continueExecution
      }
      return .fetchNext
    }

    private var immediate: UInt16 = 0
  }
}
