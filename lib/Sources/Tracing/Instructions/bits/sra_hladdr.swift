import Foundation

import LR35902

extension LR35902.Emulation {
  final class sra_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.sra(.hladdr)) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      // No trace needed.

      cpu.fsubtract = false
      cpu.fhalfcarry = false

      guard let hl: UInt16 = cpu.hl,
            let value: UInt8 = memory.read(from: hl) else {
        if let hl: UInt16 = cpu.hl {
          memory.write(nil, to: hl)
        }
        cpu.fzero = nil
        cpu.fcarry = nil
        return
      }

      let carry = (value & 1) != 0
      // msb does not change, so we use int8 to ensure the msb stays set
      let result = UInt8(bitPattern: Int8(bitPattern: value) &>> 1)
      cpu.fzero = result == 0
      cpu.fcarry = carry
      memory.write(result, to: hl)
    }
  }
}
