import Foundation

import LR35902

extension LR35902.Emulation {
  final class jr_cnd_nn: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .jr(let cnd, .simm8) = spec else {
        return nil
      }
      self.cnd = cnd
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      // No trace needed.

      defer {
        cpu.pc &+= 1
      }

      guard let imm8: UInt8 = memory.read(from: cpu.pc) else {
        return
      }
      let simm8: Int8 = Int8(bitPattern: imm8)
      if passesCondition(cnd: cnd, cpu: cpu) == true {
        cpu.pc &+= UInt16(bitPattern: Int16(truncatingIfNeeded: simm8))
      }
    }

    private let cnd: LR35902.Instruction.Condition?
  }
}
