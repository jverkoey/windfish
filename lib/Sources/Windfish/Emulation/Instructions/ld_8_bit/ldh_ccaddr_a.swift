import Foundation

extension LR35902.Emulation {
  final class ldh_ccaddr_a: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.ffccaddr, .a) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      let address = UInt16(0xFF00) | UInt16(truncatingIfNeeded: cpu.c)
      memory.write(cpu.a, to: address)
    }
  }
}
