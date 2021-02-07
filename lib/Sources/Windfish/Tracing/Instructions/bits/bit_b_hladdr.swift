import Foundation

import LR35902

extension LR35902.Emulation {
  final class bit_b_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.bit(let bit, .hladdr)) = spec else {
        return nil
      }
      self.bit = bit
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      cpu.fsubtract = false
      cpu.fhalfcarry = true
      guard let value: UInt8 = read(address: cpu.hl, from: memory) else {
        cpu.fzero = nil
        return
      }
      cpu.fzero = (value & (UInt8(1) << bit.rawValue)) == 0
    }

    private let bit: LR35902.Instruction.Bit
  }
}
