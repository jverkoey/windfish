import Foundation

import LR35902

extension LR35902.Emulation {
  final class ld_a_ffnnaddr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.a, .ffimm8addr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      defer {
        cpu.pc &+= 1
      }
      guard let lowByte: UInt8 = memory.read(from: cpu.pc) else {
        memory.registerTraces[.a] = []
        cpu.a = nil
        return
      }
      let address: UInt16 = 0xFF00 | UInt16(truncatingIfNeeded: lowByte)
      memory.registerTraces[.a] = [.loadFromAddress(address)]

      guard let value: UInt8 = memory.read(from: address) else {
        cpu.a = nil
        return
      }
      cpu.a = value
    }
  }
}
