import Foundation

extension LR35902.Emulation {
  final class add_a_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .add(.a, .imm8) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        immediate = UInt8(memory.read(from: cpu.pc))
        cpu.pc += 1
        return .continueExecution
      }
      let originalValue = cpu.a
      let result = originalValue.addingReportingOverflow(immediate)
      cpu.fzero = result.partialValue == 0
      cpu.fsubtract = false
      cpu.fcarry = result.overflow
      cpu.fhalfcarry = (((originalValue & 0x0f) + (immediate & 0x0f)) & 0x10) > 0
      cpu.a = result.partialValue
      return .fetchNext
    }

    private var immediate: UInt8 = 0
  }
}
