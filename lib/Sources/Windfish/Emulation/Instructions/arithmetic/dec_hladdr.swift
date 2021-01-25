import Foundation

extension LR35902.Emulation {
  final class dec_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .dec(.hladdr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      cpu.fsubtract = true

      guard let hl = cpu.hl,
            var value: UInt8 = memory.read(from: hl) else {
        cpu.fzero = nil
        cpu.fhalfcarry = nil
        if let hl = cpu.hl {
          memory.write(nil, to: hl)
        }
        return
      }
      // fcarry not affected
      value &-= 1
      cpu.fzero = value == 0
      cpu.fhalfcarry = (value & 0xf) == 0xf
      memory.write(value, to: hl)
    }
  }
}
