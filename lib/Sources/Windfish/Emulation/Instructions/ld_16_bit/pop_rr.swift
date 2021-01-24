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

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      cpu.registerTraces[dst] = .init(sourceLocation: sourceLocation, loadAddress: cpu.sp)
      value = UInt16(truncatingIfNeeded: memory.read(from: cpu.sp))
      cpu.sp += 1
      value |= UInt16(truncatingIfNeeded: memory.read(from: cpu.sp)) << 8
      cpu.sp += 1
      cpu[dst] = value
    }

    private let dst: LR35902.Instruction.Numeric
    private var value: UInt16 = 0
  }
}
