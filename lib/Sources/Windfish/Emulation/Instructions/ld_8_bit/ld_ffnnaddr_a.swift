import Foundation

extension LR35902.Emulation {
  final class ld_ffnnaddr_a: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.ffimm8addr, .a) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      defer {
        cpu.pc &+= 1
      }
      guard let lowByte: UInt8 = memory.read(from: cpu.pc) else {
        return
      }
      let address: UInt16 = 0xFF00 | UInt16(truncatingIfNeeded: lowByte)
      cpu.registerTraces[.a, default: []].append(.storeToAddress(address))

      memory.write(cpu.a, to: address)
    }
  }
}
