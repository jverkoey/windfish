import Foundation

extension LR35902.Emulation {
  final class add_hl_rr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers16 = LR35902.Instruction.Numeric.registers16
      guard case .add(.hl, let src) = spec, registers16.contains(src) else {
        return nil
      }
      self.src = src
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      add(cpu: cpu, value: cpu[src] as UInt16)
    }

    private let src: LR35902.Instruction.Numeric
  }
}
