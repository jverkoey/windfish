import Foundation

extension LR35902.Emulation {
  final class ld_a_nnaddr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.a, .imm16addr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      immediate = UInt16(truncatingIfNeeded: memory.read(from: cpu.pc))
      cpu.pc += 1
      immediate |= UInt16(truncatingIfNeeded: memory.read(from: cpu.pc)) << 8
      cpu.pc += 1
      value = memory.read(from: immediate)
      cpu.a = value
      cpu.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: immediate)
    }

    private var immediate: UInt16 = 0
    private var value: UInt8 = 0
  }
}
