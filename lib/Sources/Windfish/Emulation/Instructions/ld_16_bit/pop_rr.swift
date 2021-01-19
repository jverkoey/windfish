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

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Gameboy.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        cpu.registerTraces[dst] = .init(sourceLocation: sourceLocation, loadAddress: cpu.sp)
        value = UInt16(truncatingIfNeeded: memory.read(from: cpu.sp))
        cpu.sp += 1
        return .continueExecution
      }
      if cycle == 2 {
        value |= UInt16(truncatingIfNeeded: memory.read(from: cpu.sp)) << 8
        cpu.sp += 1
        return .continueExecution
      }
      cpu[dst] = value
      return .fetchNext
    }

    private let dst: LR35902.Instruction.Numeric
    private var value: UInt16 = 0
  }
}
