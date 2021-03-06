import Foundation

import LR35902

extension LR35902.Emulation {
  final class ldh_a_ccaddr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.a, .ffccaddr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      guard let lowByte: UInt8 = cpu.c else {
        memory.registerTraces[.a] = []
        return
      }
      let address = UInt16(0xFF00) | UInt16(truncatingIfNeeded: lowByte)
      memory.registerTraces[.a] = [.loadFromAddress(address)]

      cpu.a = memory.read(from: address)
    }
  }
}
