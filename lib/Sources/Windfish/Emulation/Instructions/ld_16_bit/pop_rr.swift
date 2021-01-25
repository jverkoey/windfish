import Foundation

extension LR35902.Emulation {
  final class pop_rr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers16 = LR35902.Instruction.Numeric.registers16
      guard case .pop(let dst) = spec, registers16.contains(dst) else {
        return nil
      }
      self.dst = dst
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      guard let sp = cpu.sp else {
        return
      }
      cpu.registerTraces[dst] = [.loadFromAddress(sp)]
      if let lowRegister: LR35902.Instruction.Numeric = dst.lowRegister {
        cpu.registerTraces[lowRegister] = [.loadFromAddress(sp)]
      }
      if let highRegister: LR35902.Instruction.Numeric = dst.highRegister {
        cpu.registerTraces[highRegister] = [.loadFromAddress(sp &+ 1)]
      }

      cpu.sp = sp &+ 2

      guard let lowByte: UInt8 = memory.read(from: sp),
            let highByte: UInt8 = memory.read(from: sp &+ 1) else {
        cpu.set(numeric16: dst, to: nil)
        return
      }
      cpu[dst] = (UInt16(truncatingIfNeeded: highByte) << 8) | UInt16(truncatingIfNeeded: lowByte)
    }

    private let dst: LR35902.Instruction.Numeric
    private var value: UInt16 = 0
  }
}
