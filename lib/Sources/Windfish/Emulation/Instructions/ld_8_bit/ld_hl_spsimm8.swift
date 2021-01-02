import Foundation

extension LR35902.Emulation {
  final class ld_hl_spsimm8: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.hl, .sp_plus_simm8) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        let immediate = Int8(bitPattern: memory.read(from: cpu.pc))
        wideImmediate = UInt16(bitPattern: Int16(truncatingIfNeeded: immediate))
        cpu.pc += 1
        return .continueExecution
      }
      if cycle == 2 {
        cpu.fzero = false
        cpu.fsubtract = false
        cpu.fcarry = (cpu.sp & 0xFF) &+ (wideImmediate & 0xFF) > 0xFF
        cpu.fhalfcarry = (cpu.sp & 0xF) &+ (wideImmediate & 0xF) > 0xF
        return .continueExecution
      }
      cpu.hl = cpu.sp &+ wideImmediate
      return .fetchNext
    }

    private var wideImmediate: UInt16 = 0
  }
}
