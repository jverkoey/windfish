import Foundation

extension LR35902.Emulation {
  final class ld_nnaddr_a: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.imm16addr, .a) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      defer {
        cpu.pc += 2
      }
      guard let lowByte: UInt8 = memory.read(from: cpu.pc),
            let highByte: UInt8 = memory.read(from: cpu.pc + 1) else {
        return
      }
      let address: UInt16 = (UInt16(truncatingIfNeeded: highByte) << 8) | UInt16(truncatingIfNeeded: lowByte)
      cpu.registerTraces[.a, default: []].append(.storeToAddress(address))

      memory.write(cpu.a, to: address)
    }
  }
}
