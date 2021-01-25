import Foundation

extension LR35902.Emulation {
  final class sub_a_r: InstructionEmulator, InstructionEmulatorInitializable {
    init?(spec: LR35902.Instruction.Spec) {
      let registers8 = LR35902.Instruction.Numeric.registers8
      guard case .sub(.a, let register) = spec, registers8.contains(register) else {
        return nil
      }
      self.register = register
    }

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      cpu.registerTraces[.a, default: []].append(contentsOf: cpu.registerTraces[register] ?? [])

      subNoCarry(cpu: cpu, value: cpu[register] as UInt8?)
    }

    private let register: LR35902.Instruction.Numeric
  }
}
