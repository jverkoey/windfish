import Foundation

import LR35902

// References:
// - https://stackoverflow.com/questions/57958631/game-boy-half-carry-flag-and-16-bit-instructions-especially-opcode-0xe8

extension LR35902.Emulation {
  final class add_sp_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .add(.sp, .imm8) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      memory.registerTraces[.sp, default: []].append(.mutationWithImmediateAtSourceLocation(sourceLocation))

      cpu.fzero = false
      cpu.fsubtract = false
      defer {
        cpu.pc &+= 1
      }

      guard let imm8: UInt8 = memory.read(from: cpu.pc),
            let sp = cpu.sp else {
        cpu.fcarry = nil
        cpu.fhalfcarry = nil
        cpu.sp = nil
        return
      }

      let simm8: Int8 = Int8(bitPattern: imm8)
      let imm16 = UInt16(bitPattern: Int16(truncatingIfNeeded: simm8))
      cpu.fcarry = (sp & 0xff) &+ (imm16 & 0xff) > 0xff
      cpu.fhalfcarry = (sp & 0xf) &+ (imm16 & 0xf) > 0xf
      cpu.sp = sp &+ imm16
    }
  }
}
