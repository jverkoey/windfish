import Foundation

import LR35902

extension LR35902.Emulation {
  final class ldh_ccaddr_a: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.ffccaddr, .a) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      guard let lowByte = cpu.c else {
        return
      }
      let address = UInt16(0xFF00) | UInt16(truncatingIfNeeded: lowByte)
      memory.registerTraces[.a, default: []].append(.storeToAddress(address))

      memory.write(cpu.a, to: address)
    }
  }
}
