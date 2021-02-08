import Foundation

import LR35902

extension LR35902.Emulation {
  final class ld_r_rraddr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      let registersAddr = LR35902.Instruction.Numeric.registersAddr
      guard case .ld(let dst, let src) = spec, registers8.contains(dst) && registersAddr.contains(src) else {
        return nil
      }
      self.dst = dst
      self.src = src
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      guard let address: UInt16 = cpu[src] else {
        memory.registerTraces[dst] = []
        cpu.set(numeric8: dst, to: nil)
        return
      }
      memory.registerTraces[dst] = [.loadFromAddress(address)]

      cpu[dst] = memory.read(from: address)
    }

    private let dst: LR35902.Instruction.Numeric
    private let src: LR35902.Instruction.Numeric
  }
}
