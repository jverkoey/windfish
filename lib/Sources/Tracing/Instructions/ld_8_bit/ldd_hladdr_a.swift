import Foundation

import LR35902

extension LR35902.Emulation {
  final class ldd_hladdr_a: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ldd(.hladdr, .a) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      guard let address: UInt16 = cpu.hl else {
        return
      }
      memory.registerTraces[.a, default: []].append(.storeToAddress(address))

      memory.write(cpu.a, to: address)
      cpu.hl = address &- 1
    }
  }
}
