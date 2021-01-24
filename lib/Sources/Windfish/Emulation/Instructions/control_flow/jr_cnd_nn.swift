import Foundation

extension LR35902.Emulation {
  final class jr_cnd_nn: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .jr(let cnd, .simm8) = spec else {
        return nil
      }
      self.cnd = cnd
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      immediate = Int8(bitPattern: memory.read(from: cpu.pc))
      cpu.pc += 1
      if passesCondition(cnd: cnd, cpu: cpu) {
        cpu.pc &+= UInt16(bitPattern: Int16(truncatingIfNeeded: immediate))
      }
    }

    private let cnd: LR35902.Instruction.Condition?
    private var immediate: Int8 = 0
  }
}
