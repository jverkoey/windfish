import Foundation

import LR35902

extension LR35902.Emulation {
  final class inc_rr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers16 = LR35902.Instruction.Numeric.registers16
      guard case .inc(let register) = spec, registers16.contains(register) else {
        return nil
      }
      self.register = register
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      // No trace needed.

      guard let value: UInt16 = cpu[register] else {
        return
      }
      cpu[register] = value &+ 1
    }

    private let register: LR35902.Instruction.Numeric
  }
}
