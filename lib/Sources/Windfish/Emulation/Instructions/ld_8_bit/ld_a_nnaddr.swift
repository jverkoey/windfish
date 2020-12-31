import Foundation

extension LR35902.Emulation {
  final class ld_a_nnadr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.a, .imm16addr) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
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
        value = memory.read(from: immediate)
        return .continueExecution
      }
      cpu.a = value
      cpu.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: immediate)
      return .fetchNext
    }

    private var immediate: UInt16 = 0
    private var value: UInt8 = 0
  }
}
