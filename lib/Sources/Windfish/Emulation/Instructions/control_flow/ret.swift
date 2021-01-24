import Foundation

extension LR35902.Emulation {
  final class ret: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ret(nil) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      pc = UInt16(truncatingIfNeeded: memory.read(from: cpu.sp))
      cpu.sp &+= 1
      pc |= UInt16(truncatingIfNeeded: memory.read(from: cpu.sp)) << 8
      cpu.sp &+= 1
      cpu.pc = pc
    }

    private var pc: UInt16 = 0
  }
}
