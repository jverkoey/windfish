import Foundation

extension LR35902.Emulation {
  final class rst_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .rst(let address) = spec else {
        return nil
      }
      self.address = address
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Gameboy.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        return .continueExecution
      }
      if cycle == 2 {
        cpu.sp &-= 1
        memory.write(UInt8(truncatingIfNeeded: (cpu.pc & 0xFF00) >> 8), to: cpu.sp)
        return .continueExecution
      }
      if cycle == 3 {
        cpu.sp &-= 1
        memory.write(UInt8(truncatingIfNeeded: cpu.pc & 0x00FF), to: cpu.sp)
        return .continueExecution
      }
      cpu.pc = LR35902.Address(address.rawValue)
      return .fetchNext
    }

    private let address: LR35902.Instruction.RestartAddress
  }
}
