import Foundation

import LR35902

extension LR35902.Emulation {
  final class sbc_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .sbc(.imm8) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      memory.registerTraces[.a, default: []].append(.mutationWithImmediateAtSourceLocation(sourceLocation))

      subConsideringCarry(cpu: cpu, value: memory.read(from: cpu.pc))
      cpu.pc &+= 1
    }
  }
}
