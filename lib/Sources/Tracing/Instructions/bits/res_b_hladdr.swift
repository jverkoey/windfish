import Foundation

import LR35902

extension LR35902.Emulation {
  final class res_b_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.res(let bit, .hladdr)) = spec else {
        return nil
      }
      self.bit = bit
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      guard let hl = cpu.hl else {
        return
      }
      guard var value: UInt8 = memory.read(from: hl) else {
        memory.write(nil, to: hl)
        return
      }
      value &= ~(UInt8(1) << bit.rawValue)
      memory.write(value, to: hl)
    }

    private let bit: LR35902.Instruction.Bit
  }
}
