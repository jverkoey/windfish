import Foundation

import LR35902

extension LR35902.Emulation {
  final class add_a_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .add(.a, .imm8) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      memory.registerTraces[.a, default: []].append(.mutationWithImmediateAtSourceLocation(sourceLocation))

      addNoCarry(cpu: cpu, value: memory.read(from: cpu.pc))
      cpu.pc &+= 1
    }
  }
}
