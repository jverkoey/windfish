import Foundation

import LR35902

extension LR35902.Emulation {
  final class add_hl_rr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers16 = LR35902.Instruction.Numeric.registers16
      guard case .add(.hl, let src) = spec, registers16.contains(src) else {
        return nil
      }
      self.src = src
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      memory.registerTraces[.hl, default: []].append(contentsOf: memory.registerTraces[src] ?? [])

      cpu.fsubtract = false
      // Intentionally no modification of cpu.fzero

      guard let hl: UInt16 = cpu.hl,
            let value: UInt16 = cpu[src] else {
        cpu.hl = nil
        cpu.fcarry = nil
        cpu.fhalfcarry = nil
        return
      }
      let wideHL: UInt32 = UInt32(truncatingIfNeeded: hl)
      let wideVal: UInt32 = UInt32(truncatingIfNeeded: value)

      let halfResult: UInt32 = (wideHL & 0xfff) + (wideVal & 0xfff)
      let fullResult: UInt32 = wideHL + wideVal

      cpu.hl = UInt16(truncatingIfNeeded: fullResult)
      cpu.fcarry = fullResult > 0xffff
      cpu.fhalfcarry = halfResult > 0xfff
    }

    private let src: LR35902.Instruction.Numeric
  }
}
