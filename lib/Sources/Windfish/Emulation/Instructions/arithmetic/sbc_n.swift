import Foundation

extension LR35902.Emulation {
  final class sbc_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .sbc(.imm8) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        immediate = UInt8(memory.read(from: cpu.pc))
        cpu.pc += 1
        return .continueExecution
      }

      immediate &+= cpu.fcarry ? 1 : 0

      let originalValue = cpu.a
      let result = originalValue.subtractingReportingOverflow(immediate)
      cpu.fzero = result.partialValue == 0
      cpu.fsubtract = true
      cpu.fcarry = result.overflow
      cpu.fhalfcarry = (cpu.a & 0x0f) < (immediate & 0x0f)
      cpu.a = result.partialValue
      return .fetchNext
    }

    private var immediate: UInt8 = 0
  }
}
