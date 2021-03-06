import Foundation

import LR35902

extension LR35902.Emulation {
  final class ld_r_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .ld(let dst, let src) = spec, registers8.contains(dst) && registers8.contains(src) else {
        return nil
      }
      self.dst = dst
      self.src = src
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      memory.registerTraces[dst] = memory.registerTraces[src]

      guard let value: UInt8 = cpu[src] else {
        cpu.set(numeric8: dst, to: nil)
        return
      }
      cpu[dst] = value
    }

    private let dst: LR35902.Instruction.Numeric
    private let src: LR35902.Instruction.Numeric
  }
}
