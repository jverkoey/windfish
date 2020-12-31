import Foundation

protocol InstructionEmulator: class {
  init?(spec: LR35902.Instruction.Spec)
  func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult
}

extension LR35902 {
  final class Emulation {}
}

extension LR35902.Emulation {

  private static var instructionEmulatorFactories: [InstructionEmulator.Type] = [
    ld_r_r.self
  ]

  static let instructionEmulators: [InstructionEmulator] = {
    return LR35902.InstructionSet.allSpecs().map { spec in
      let instructions = instructionEmulatorFactories.compactMap { $0.init(spec: spec) }
      precondition(instructions.count == 1)
      return instructions.first!
    }
  }()

  final class ld_r_r: InstructionEmulator {
    let dst: LR35902.Instruction.Numeric
    let src: LR35902.Instruction.Numeric

    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      switch spec {
      case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
        self.dst = dst
        self.src = src
      default:
        return nil
      }
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult {
      cpu[dst] = cpu[src] as UInt8
      cpu.registerTraces[dst] = cpu.registerTraces[src]
      return .fetchNext
    }
  }
}
