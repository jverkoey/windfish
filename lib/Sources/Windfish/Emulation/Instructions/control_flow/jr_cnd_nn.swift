import Foundation

extension LR35902.Emulation {
  final class jr_cnd_nn: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .jr(let cnd, .simm8) = spec else {
        return nil
      }
      self.cnd = cnd
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Gameboy.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        immediate = Int8(bitPattern: memory.read(from: cpu.pc))
        cpu.pc += 1
        return .continueExecution
      }
      if cycle == 2 {
        return checkConditional(cnd: cnd, cpu: cpu)
      }
      cpu.pc &+= UInt16(bitPattern: Int16(truncatingIfNeeded: immediate))
      return .fetchNext
    }

    private let cnd: LR35902.Instruction.Condition?
    private var immediate: Int8 = 0
  }
}
