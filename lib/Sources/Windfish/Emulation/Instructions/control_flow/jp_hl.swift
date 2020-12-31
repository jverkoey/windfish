import Foundation

extension LR35902.Emulation {
  final class jp_hl: InstructionEmulator {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .jp(nil, .hl) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult {
      cpu.pc = cpu.hl
      return .fetchNext
    }

    private var immediate: UInt16 = 0
  }
}
