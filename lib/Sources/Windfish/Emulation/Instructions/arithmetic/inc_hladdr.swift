import Foundation

extension LR35902.Emulation {
  final class inc_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .inc(.hladdr) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Gameboy.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        value = memory.read(from: cpu.hl)
        return .continueExecution
      }
      if cycle == 2 {
        cpu.fsubtract = false
        // fcarry not affected
        let result = value &+ 1
        memory.write(result, to: cpu.hl)
        cpu.fzero = result == 0
        cpu.fhalfcarry = (result & 0xF) == 0
        return .continueExecution
      }
      return .fetchNext
    }

    private var value: UInt8 = 0
  }
}
