import Foundation

import LR35902

extension LR35902.Emulation {
  final class and_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .and(.imm8) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      memory.registerTraces[.a, default: []].append(.mutationWithImmediateAtSourceLocation(sourceLocation))

      cpu.fsubtract = false
      cpu.fcarry = false
      cpu.fhalfcarry = true

      defer {
        cpu.pc &+= 1
      }
      guard let a: UInt8 = cpu.a,
            let value: UInt8 = memory.read(from: cpu.pc) else {
        cpu.a = nil
        cpu.fzero = nil
        return
      }
      let result = a & value
      cpu.a = result
      cpu.fzero = result == 0
    }
  }
}
