import Foundation

import LR35902

extension LR35902.Emulation {
  final class call_cnd_nn: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .call(let cnd, .imm16) = spec else {
        return nil
      }
      self.cnd = cnd
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      guard let lowByte: UInt8 = memory.read(from: cpu.pc),
            let highByte: UInt8 = memory.read(from: cpu.pc + 1) else {
        cpu.sp = nil
        cpu.pc += 2
        return
      }
      let jumpAddress = (UInt16(truncatingIfNeeded: highByte) << 8) | UInt16(truncatingIfNeeded: lowByte)

      cpu.pc += 2

      if passesCondition(cnd: cnd, cpu: cpu) == true {
        guard var sp = cpu.sp else {
          return
        }
        sp &-= 1
        memory.write(UInt8(truncatingIfNeeded: (cpu.pc & 0xFF00) >> 8), to: sp)
        sp &-= 1
        memory.write(UInt8(truncatingIfNeeded: cpu.pc & 0x00FF), to: sp)
        cpu.sp = sp
        cpu.pc = jumpAddress
      }
    }

    private let cnd: LR35902.Instruction.Condition?
  }
}
