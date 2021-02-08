import Foundation

import LR35902

extension LR35902.Emulation {
  final class ldi_a_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ldi(.a, .hladdr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      guard let address: UInt16 = cpu.hl else {
        memory.registerTraces[.a] = []
        cpu.a = nil
        return
      }
      memory.registerTraces[.a] = [.loadFromAddress(address)]

      cpu.a = memory.read(from: address)
      cpu.hl = address &+ 1
    }
  }
}
