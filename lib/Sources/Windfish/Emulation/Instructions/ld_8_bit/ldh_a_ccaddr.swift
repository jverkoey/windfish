import Foundation

extension LR35902.Emulation {
  final class ldh_a_ccaddr: InstructionEmulator {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ld(.a, .ffccaddr) = spec else {
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult {
      if cycle == 1 {
        let address = UInt16(0xFF00) | UInt16(truncatingIfNeeded: cpu.c)
        value = memory.read(from: address)
        cpu.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: address)
        return .continueExecution
      }
      cpu.a = value
      return .fetchNext
    }

    private var value: UInt8 = 0
  }
}
