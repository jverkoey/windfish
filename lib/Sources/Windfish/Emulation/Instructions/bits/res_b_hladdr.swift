import Foundation

extension LR35902.Emulation {
  final class res_b_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.res(let bit, .hladdr)) = spec else {
        return nil
      }
      self.bit = bit
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      value = memory.read(from: cpu.hl)
      value &= ~(UInt8(1) << bit.rawValue)
      memory.write(value, to: cpu.hl)
    }

    private let bit: LR35902.Instruction.Bit
    private var value: UInt8 = 0
  }
}
