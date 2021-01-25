import Foundation

extension LR35902.Emulation {
  final class ldd_a_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ldd(.a, .hladdr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      guard let address = cpu.hl else {
        cpu.registerTraces[.a] = []
        cpu.a = nil
        return
      }
      cpu.registerTraces[.a] = [.loadFromAddress(address)]

      cpu.a = memory.read(from: address)
      cpu.hl = address &- 1
    }
  }
}
