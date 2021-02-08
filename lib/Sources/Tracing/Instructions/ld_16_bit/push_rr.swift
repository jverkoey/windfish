import Foundation

import LR35902

extension LR35902.Emulation {
  final class push_rr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers16 = LR35902.Instruction.Numeric.registers16
      guard case .push(let src) = spec, registers16.contains(src) else {
        return nil
      }
      self.src = src
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      guard let sp = cpu.sp else {
        return
      }
      memory.registerTraces[src, default: []].append(.storeToAddress(sp &- 2))
      if let lowRegister: LR35902.Instruction.Numeric = src.lowRegister {
        memory.registerTraces[lowRegister, default: []].append(.storeToAddress(sp &- 2))
      }
      if let highRegister: LR35902.Instruction.Numeric = src.highRegister {
        memory.registerTraces[highRegister, default: []].append(.storeToAddress(sp &- 1))
      }

      cpu.sp = sp &- 2

      guard let imm16: UInt16 = cpu[src] else {
        memory.write(nil, to: sp)
        memory.write(nil, to: sp)
        return
      }
      memory.write(UInt8(truncatingIfNeeded: (imm16 & 0xFF00) >> 8), to: sp &- 1)
      memory.write(UInt8(truncatingIfNeeded: imm16 & 0x00FF), to: sp &- 2)
    }

    private let src: LR35902.Instruction.Numeric
  }
}
