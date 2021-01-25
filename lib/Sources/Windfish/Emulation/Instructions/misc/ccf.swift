import Foundation

extension LR35902.Emulation {
  final class ccf: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      guard case .ccf = spec else {
        return nil
      }
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      // cpu.fzero is not affected
      cpu.fsubtract = false
      cpu.fhalfcarry = false

      guard let fcarry: Bool = cpu.fcarry else {
        return
      }
      cpu.fcarry = !fcarry
    }
  }
}
