import Foundation

extension LR35902.Emulation {
  final class ldd_a_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ldd(.a, .hladdr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      cpu.a = memory.read(from: cpu.hl)
      cpu.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: cpu.hl)
      cpu.hl -= 1
    }
  }
}
