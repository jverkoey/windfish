import Foundation

import LR35902

extension LR35902.Emulation {
  final class ld_r_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .ld(let dst, .imm8) = spec, registers8.contains(dst) else {
        return nil
      }
      self.dst = dst
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      memory.registerTraces[dst] = [.loadImmediateFromSourceLocation(sourceLocation)]

      defer {
        cpu.pc &+= 1
      }
      guard let value: UInt8 = memory.read(from: cpu.pc) else {
        cpu.set(numeric8: dst, to: nil)
        return
      }
      cpu[dst] = value
    }

    private let dst: LR35902.Instruction.Numeric
  }
}
