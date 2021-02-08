import Foundation

import LR35902

extension LR35902.Emulation {
  final class ld_hl_spsimm8: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.hl, .sp_plus_simm8) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Tracer.SourceLocation) {
      cpu.fzero = false
      cpu.fsubtract = false

      defer {
        cpu.pc &+= 1
      }
      guard let imm8: UInt8 = memory.read(from: cpu.pc),
            let sp: UInt16 = cpu.sp else {
        cpu.fcarry = nil
        cpu.fhalfcarry = nil
        cpu.hl = nil
        memory.registerTraces[.hl] = []
        return
      }
      let simm8: Int8 = Int8(bitPattern: imm8)
      let imm16: UInt16 = UInt16(bitPattern: Int16(truncatingIfNeeded: simm8))
      let address: UInt16 = sp &+ imm16

      memory.registerTraces[.hl] = [.loadFromAddress(address)]
      memory.registerTraces[.l] = [.loadFromAddress(address)]
      memory.registerTraces[.h] = [.loadFromAddress(address &+ 1)]

      cpu.fcarry = (sp & 0xFF) &+ (imm16 & 0xFF) > 0xFF
      cpu.fhalfcarry = (sp & 0xF) &+ (imm16 & 0xF) > 0xF
      cpu.hl = sp &+ imm16
    }
  }
}
