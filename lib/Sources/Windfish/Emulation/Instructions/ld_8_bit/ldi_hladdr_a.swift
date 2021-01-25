import Foundation

extension LR35902.Emulation {
  final class ldi_hladdr_a: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ldi(.hladdr, .a) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      guard let address: UInt16 = cpu.hl else {
        return
      }
      cpu.registerTraces[.a, default: []].append(.storeToAddress(address))

      memory.write(cpu.a, to: address)
      cpu.hl = address &+ 1
    }
  }
}
