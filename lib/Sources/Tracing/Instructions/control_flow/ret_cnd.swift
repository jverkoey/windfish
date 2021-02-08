import Foundation

import LR35902

extension LR35902.Emulation {
  final class ret_cnd: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ret(let cnd) = spec, cnd != nil else {
        return nil
      }
      self.cnd = cnd
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      // No trace needed.

      if passesCondition(cnd: cnd, cpu: cpu) == true {
        guard let sp = cpu.sp,
              let lowByte: UInt8 = memory.read(from: sp),
              let highByte: UInt8 = memory.read(from: sp &+ 1) else {
          cpu.sp = nil
          return
        }
        cpu.pc = (UInt16(truncatingIfNeeded: highByte) << 8) | UInt16(truncatingIfNeeded: lowByte)
        cpu.sp = sp &+ 2
      }
    }

    private let cnd: LR35902.Instruction.Condition?
  }
}
