import Foundation

extension LR35902.Emulation {
  final class jp_cnd_nn: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .jp(let cnd, .imm16) = spec else {
        return nil
      }
      self.cnd = cnd
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      guard let lowByte: UInt8 = memory.read(from: cpu.pc),
            let highByte: UInt8 = memory.read(from: cpu.pc + 1) else {
        return
      }
      let jumpAddress = (UInt16(truncatingIfNeeded: highByte) << 8) | UInt16(truncatingIfNeeded: lowByte)

      cpu.pc += 2

      if passesCondition(cnd: cnd, cpu: cpu) == true {
        cpu.pc = jumpAddress
      }
    }

    private let cnd: LR35902.Instruction.Condition?
  }
}
