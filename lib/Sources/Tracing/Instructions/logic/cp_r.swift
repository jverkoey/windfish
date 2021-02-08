import Foundation

import LR35902

extension LR35902.Emulation {
  final class cp_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .cp(let register) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      memory.registerTraces[.a, default: []].append(contentsOf: memory.registerTraces[register] ?? [])

      cpu.fsubtract = true

      guard let a: UInt8 = cpu.a,
            let value: UInt8 = cpu[register] else {
        cpu.a = nil
        cpu.fzero = nil
        cpu.fcarry = nil
        cpu.fhalfcarry = nil
        return
      }
      let wideA = UInt16(truncatingIfNeeded: a)
      let wideVal = UInt16(truncatingIfNeeded: value)

      let halfResult: UInt16 = (wideA & 0xf) &- (wideVal & 0xf)
      let fullResult: UInt16 = wideA &- wideVal

      let result = UInt8(truncatingIfNeeded: fullResult)
      cpu.fzero = result == 0
      cpu.fcarry = fullResult > 0xff
      cpu.fhalfcarry = halfResult > 0xf
    }

    private let register: LR35902.Instruction.Numeric
  }
}
