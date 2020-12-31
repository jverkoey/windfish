import Foundation

extension LR35902.Emulation {
  final class ld_rraddr_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      let registersAddr = LR35902.Instruction.Numeric.registersAddr
      guard case .ld(let dst, let src) = spec, registersAddr.contains(dst) && registers8.contains(src) else {
        return nil
      }
      self.dst = dst
      self.src = src
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      if cycle == 1 {
        memory.write(cpu[src], to: cpu[dst])
        return .continueExecution
      }
      return .fetchNext
    }

    private let dst: LR35902.Instruction.Numeric
    private let src: LR35902.Instruction.Numeric
  }
}
