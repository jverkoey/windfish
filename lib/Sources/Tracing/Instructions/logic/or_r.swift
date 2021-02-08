import Foundation

import LR35902

extension LR35902.Emulation {
  final class or_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .or(let register) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      memory.registerTraces[.a, default: []].append(contentsOf: memory.registerTraces[register] ?? [])

      cpu.fsubtract = false
      cpu.fcarry = false
      cpu.fhalfcarry = false

      guard let a: UInt8 = cpu.a,
            let value: UInt8 = cpu[register] else {
        cpu.a = nil
        cpu.fzero = nil
        return
      }
      let result = a | value
      cpu.a = result
      cpu.fzero = result == 0
    }

    private let register: LR35902.Instruction.Numeric
  }
}
