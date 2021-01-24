import Foundation

extension LR35902.Emulation {
  final class rst_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .rst(let address) = spec else {
        return nil
      }
      self.address = address
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      cpu.sp &-= 1
      memory.write(UInt8(truncatingIfNeeded: (cpu.pc & 0xFF00) >> 8), to: cpu.sp)
      cpu.sp &-= 1
      memory.write(UInt8(truncatingIfNeeded: cpu.pc & 0x00FF), to: cpu.sp)
      cpu.pc = LR35902.Address(address.rawValue)
    }

    private let address: LR35902.Instruction.RestartAddress
  }
}
