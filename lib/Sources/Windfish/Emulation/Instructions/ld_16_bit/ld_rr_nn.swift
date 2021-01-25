import Foundation

extension LR35902.Emulation {
  final class ld_rr_nn: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers16 = LR35902.Instruction.Numeric.registers16
      guard case .ld(let dst, .imm16) = spec, registers16.contains(dst) else {
        return nil
      }
      self.dst = dst
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      defer {
        cpu.pc &+= 2
      }
      guard let lowByte: UInt8 = memory.read(from: cpu.pc),
            let highByte: UInt8 = memory.read(from: cpu.pc + 1) else {
        return
      }
      let address: UInt16 = (UInt16(truncatingIfNeeded: highByte) << 8) | UInt16(truncatingIfNeeded: lowByte)
      cpu.registerTraces[dst] = [.loadImmediateFromSourceLocation(sourceLocation)]
      if let lowRegister: LR35902.Instruction.Numeric = dst.lowRegister {
        cpu.registerTraces[lowRegister] = [.loadImmediateFromSourceLocation(sourceLocation)]
      }
      if let highRegister: LR35902.Instruction.Numeric = dst.highRegister {
        cpu.registerTraces[highRegister] = [.loadImmediateFromSourceLocation(sourceLocation)]
      }

      cpu[dst] = address
    }

    private let dst: LR35902.Instruction.Numeric
    private var immediate: UInt16 = 0
  }
}
