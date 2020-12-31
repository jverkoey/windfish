import Foundation

extension LR35902.Emulation {
  final class ld_r_rraddr: InstructionEmulator {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      let registersAddr = LR35902.Instruction.Numeric.registersAddr
      guard case .ld(let dst, let src) = spec, registers8.contains(dst) && registersAddr.contains(src) else {
        return nil
      }
      self.dst = dst
      self.src = src
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult {
      if cycle == 1 {
        let address = cpu[src] as UInt16
        value = memory.read(from: address)
        cpu.registerTraces[dst] = .init(sourceLocation: sourceLocation, loadAddress: address)
        return .continueExecution
      }
      cpu[dst] = value
      return .fetchNext
    }

    private let dst: LR35902.Instruction.Numeric
    private let src: LR35902.Instruction.Numeric
    private var value: UInt8 = 0
  }
}
