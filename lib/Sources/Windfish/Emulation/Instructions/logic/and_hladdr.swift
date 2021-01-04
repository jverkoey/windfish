import Foundation

extension LR35902.Emulation {
  final class and_hladdr: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .and(.hladdr) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        value = memory.read(from: cpu.hl)
        return .continueExecution
      }
      cpu.a &= value
      cpu.fzero = cpu.a == 0
      cpu.fsubtract = false
      cpu.fcarry = false
      cpu.fhalfcarry = true
      return .fetchNext
    }

    private var value: UInt8 = 0
  }
}
