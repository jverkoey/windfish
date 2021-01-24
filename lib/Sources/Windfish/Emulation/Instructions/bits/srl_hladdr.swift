import Foundation

extension LR35902.Emulation {
  final class srl_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .cb(.srl(.hladdr)) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      value = memory.read(from: cpu.hl)
      cpu.fsubtract = false
      cpu.fhalfcarry = false

      let carry = (value & 1) != 0
      let result = value &>> 1
      cpu.fzero = result == 0
      cpu.fcarry = carry
      value = result
      memory.write(value, to: cpu.hl)
    }

    private var value: UInt8 = 0
  }
}
