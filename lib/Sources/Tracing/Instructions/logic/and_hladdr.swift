import Foundation

import LR35902

extension LR35902.Emulation {
  final class and_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .and(.hladdr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      if let hl = cpu.hl {
        memory.registerTraces[.a, default: []].append(.mutationFromAddress(memory.sourceLocation(from: hl)))
      }

      cpu.fsubtract = false
      cpu.fcarry = false
      cpu.fhalfcarry = true

      guard let a: UInt8 = cpu.a,
            let hl: UInt16 = cpu.hl,
            let value: UInt8 = memory.read(from: hl) else {
        cpu.a = nil
        cpu.fzero = nil
        return
      }

      let result: UInt8 = a & value
      cpu.a = result
      cpu.fzero = result == 0
    }
  }
}
