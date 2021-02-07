import Foundation

import LR35902

extension LR35902.Emulation {
  final class ld_nnaddr_sp: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.imm16addr, .sp) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      defer {
        cpu.pc += 2
      }
      guard let lowByte: UInt8 = memory.read(from: cpu.pc),
            let highByte: UInt8 = memory.read(from: cpu.pc + 1) else {
        return
      }
      let address: UInt16 = (UInt16(truncatingIfNeeded: highByte) << 8) | UInt16(truncatingIfNeeded: lowByte)
      memory.registerTraces[.sp, default: []].append(.storeToAddress(address))

      guard let sp = cpu.sp else {
        memory.write(nil, to: address)
        memory.write(nil, to: address + 1)
        return
      }
      memory.write(UInt8(truncatingIfNeeded: sp & 0x00FF), to: address)
      memory.write(UInt8(truncatingIfNeeded: (sp & 0xFF00) >> 8), to: address + 1)
    }
  }
}
