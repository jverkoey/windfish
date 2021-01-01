import Foundation

extension LR35902.Emulation {
  final class add_sp_n: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .add(.sp, .imm8) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        immediate = Int8(bitPattern: memory.read(from: cpu.pc))
        cpu.pc += 1
        return .continueExecution
      }
      if cycle == 2 {
        if immediate > 0 {
          let amount = UInt16(truncatingIfNeeded: UInt8(bitPattern: immediate))
          let result = cpu.sp.addingReportingOverflow(amount)
          cpu.fhalfcarry = (((cpu.sp & 0x0fff) + (amount & 0x0fff)) & 0x1000) > 0
          cpu.sp = result.partialValue
          cpu.fcarry = result.overflow
        } else if immediate < 0 {
          let amount = UInt16(truncatingIfNeeded: UInt8(bitPattern: -immediate))
          let result = cpu.sp.subtractingReportingOverflow(amount)
          cpu.fhalfcarry = (amount & 0x0fff) > (cpu.sp & 0x0fff)
          cpu.sp = result.partialValue
          cpu.fcarry = result.overflow
        }
        return .continueExecution
      }
      if cycle == 3 {
        return .continueExecution
      }
      cpu.fsubtract = false
      return .fetchNext
    }

    private var immediate: Int8 = 0
  }
}
