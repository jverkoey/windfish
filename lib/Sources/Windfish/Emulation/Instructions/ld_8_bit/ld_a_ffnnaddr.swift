import Foundation

extension LR35902.Emulation {
  final class ld_a_ffnnaddr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.a, .ffimm8addr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      let address: UInt16 = 0xFF00 | UInt16(truncatingIfNeeded: memory.read(from: cpu.pc))
      let value: UInt8 = memory.read(from: address)
      cpu.pc += 1
      cpu.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: address)
      cpu.a = value
    }
  }
}
