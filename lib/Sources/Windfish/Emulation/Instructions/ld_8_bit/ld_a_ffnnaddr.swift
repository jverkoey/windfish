import Foundation

extension LR35902.Emulation {
  final class ld_a_ffnnaddr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.a, .ffimm8addr) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Gameboy.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        immediate = UInt16(truncatingIfNeeded: memory.read(from: cpu.pc))
        cpu.pc += 1
        return .continueExecution
      }
      if cycle == 2 {
        let address = UInt16(0xFF00) | immediate
        value = memory.read(from: address)
        cpu.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: address)
        return .continueExecution
      }
      cpu.a = value
      return .fetchNext
    }

    private var immediate: UInt16 = 0
    private var value: UInt8 = 0
  }
}
