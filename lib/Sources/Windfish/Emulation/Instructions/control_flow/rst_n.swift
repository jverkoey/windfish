import Foundation

import LR35902

extension LR35902.Emulation {
  final class rst_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .rst(let address) = spec else {
        return nil
      }
      self.address = address
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      guard var sp = cpu.sp else {
        return
      }
      sp &-= 1
      memory.write(UInt8(truncatingIfNeeded: (cpu.pc & 0xFF00) >> 8), to: sp)
      sp &-= 1
      memory.write(UInt8(truncatingIfNeeded: cpu.pc & 0x00FF), to: sp)
      cpu.sp = sp
      cpu.pc = LR35902.Address(truncatingIfNeeded: address.rawValue)
    }

    private let address: LR35902.Instruction.RestartAddress
  }
}
