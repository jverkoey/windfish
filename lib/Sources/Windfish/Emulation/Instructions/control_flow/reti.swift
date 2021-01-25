import Foundation

extension LR35902.Emulation {
  final class reti: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .reti = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // No trace needed.

      guard let sp = cpu.sp,
            let lowByte: UInt8 = memory.read(from: sp),
            let highByte: UInt8 = memory.read(from: sp &+ 1) else {
        cpu.sp = nil
        return
      }
      cpu.pc = (UInt16(truncatingIfNeeded: highByte) << 8) | UInt16(truncatingIfNeeded: lowByte)
      cpu.sp = sp &+ 2
    }

    private var pc: UInt16 = 0
  }
}
