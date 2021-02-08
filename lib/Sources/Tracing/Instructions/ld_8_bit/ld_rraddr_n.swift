import Foundation

import LR35902

extension LR35902.Emulation {
  final class ld_rraddr_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registersAddr = LR35902.Instruction.Numeric.registersAddr
      guard case .ld(let dst, .imm8) = spec, registersAddr.contains(dst) else {
        return nil
      }
      self.dst = dst
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      defer {
        cpu.pc &+= 1
      }
      guard let address: UInt16 = cpu[dst] else {
        return
      }
      // No trace; just storing a constant in memory.

      guard let imm8: UInt8 = memory.read(from: cpu.pc) else {
        memory.write(nil, to: address)
        return
      }
      memory.write(imm8, to: address)
    }

    private let dst: LR35902.Instruction.Numeric
  }
}
