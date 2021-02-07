import Foundation

import LR35902

extension LR35902.Emulation {
  final class adc_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .adc(let register) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      memory.registerTraces[.a, default: []].append(contentsOf: memory.registerTraces[register] ?? [])

      addConsideringCarry(cpu: cpu, value: cpu[register])
    }

    private let register: LR35902.Instruction.Numeric
  }
}
