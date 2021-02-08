import Foundation

import LR35902

extension LR35902.Emulation {
  final class xor_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .xor(let register) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      if register == .a {
        // xor a, a effectively zeroes out the register. Treat this as a reset of the tracer list as well.
        memory.registerTraces[.a] = []
      } else {
        memory.registerTraces[.a, default: []].append(contentsOf: memory.registerTraces[register] ?? [])
      }

      cpu.fsubtract = false
      cpu.fcarry = false
      cpu.fhalfcarry = false

      guard let a: UInt8 = cpu.a,
            let value: UInt8 = cpu[register] else {
        cpu.a = nil
        cpu.fzero = nil
        return
      }
      let result = a ^ value
      cpu.a = result
      cpu.fzero = result == 0
    }

    private let register: LR35902.Instruction.Numeric
  }
}
