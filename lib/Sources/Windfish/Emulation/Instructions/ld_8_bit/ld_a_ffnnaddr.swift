import Foundation

extension LR35902.Emulation {
  final class ld_a_ffnnaddr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.a, .ffimm8addr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      immediate = UInt16(truncatingIfNeeded: memory.read(from: cpu.pc))
      cpu.pc += 1
      let address = UInt16(0xFF00) | immediate
      value = memory.read(from: address)
      cpu.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: address)
      cpu.a = value
    }

    private var immediate: UInt16 = 0
    private var value: UInt8 = 0
  }
}
