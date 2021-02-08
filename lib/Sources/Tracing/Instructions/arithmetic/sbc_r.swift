import Foundation

import LR35902

extension LR35902.Emulation {
  final class sbc_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .sbc(let register) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      memory.registerTraces[.a, default: []].append(contentsOf: memory.registerTraces[register] ?? [])

      subConsideringCarry(cpu: cpu, value: cpu[register])
    }

    private let register: LR35902.Instruction.Numeric
  }
}
