import Foundation

extension LR35902.Emulation {
  final class ld_a_nnaddr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.a, .imm16addr) = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: AddressableMemory, sourceLocation: Gameboy.SourceLocation) {
      let lowByte: UInt8 = memory.read(from: cpu.pc)
      let highByte: UInt8 = memory.read(from: cpu.pc + 1)
      let immediate: UInt16 = UInt16(truncatingIfNeeded: highByte) << 8 | UInt16(truncatingIfNeeded: lowByte)
      let value: UInt8 = memory.read(from: immediate)
      cpu.pc += 2
      cpu.a = value
      cpu.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: immediate)
    }
  }
}
