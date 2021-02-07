import Foundation

import LR35902

extension LR35902.Emulation {
  final class ld_a_nnaddr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.a, .imm16addr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      defer {
        cpu.pc += 2
      }
      guard let lowByte: UInt8 = memory.read(from: cpu.pc),
            let highByte: UInt8 = memory.read(from: cpu.pc + 1) else {
        memory.registerTraces[.a] = []
        cpu.a = nil
        return
      }
      let address: UInt16 = (UInt16(truncatingIfNeeded: highByte) << 8) | UInt16(truncatingIfNeeded: lowByte)
      memory.registerTraces[.a] = [.loadFromAddress(address)]

      guard let value: UInt8 = memory.read(from: address) else {
        cpu.a = nil
        return
      }
      cpu.a = value
    }
  }
}
