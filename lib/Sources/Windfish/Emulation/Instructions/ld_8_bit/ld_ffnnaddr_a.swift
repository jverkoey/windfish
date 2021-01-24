import Foundation

extension LR35902.Emulation {
  final class ld_ffnnaddr_a: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.ffimm8addr, .a) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      let address: UInt16 = 0xFF00 | UInt16(truncatingIfNeeded: memory.read(from: cpu.pc))
      cpu.pc += 1
      memory.write(cpu.a, to: address)
    }
  }
}
