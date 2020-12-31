import Foundation

protocol InstructionEmulator: class {
  init?(spec: LR35902.Instruction.Spec)
  func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult
}

extension LR35902 {
  final class Emulation {}
}

extension InstructionEmulator {
  func checkConditional(cnd: LR35902.Instruction.Condition?, cpu: LR35902) -> LR35902.MachineInstruction.MicroCodeResult {
    switch cnd {
    case .none:      return .continueExecution
    case .some(.c):  return  cpu.fcarry ? .continueExecution : .fetchNext
    case .some(.nc): return !cpu.fcarry ? .continueExecution : .fetchNext
    case .some(.z):  return  cpu.fzero ? .continueExecution : .fetchNext
    case .some(.nz): return !cpu.fzero ? .continueExecution : .fetchNext
    }
  }
}

extension LR35902.Emulation {

  private static var instructionEmulatorFactories: [InstructionEmulator.Type] = [
    // Control flow
    call_cnd_nn.self,
    jp_cnd_nn.self,
    jp_hl.self,
    jr_cnd_nn.self,
    ret_cnd.self,
    reti.self,
    rst_n.self,

    // 8-bit loads
    ld_a_ffnnaddr.self,
    ld_a_nnadr.self,
    ld_ffnnaddr_a.self,
    ld_nnaddr_sp.self,
    ld_nnadr_a.self,
    ld_r_n.self,
    ld_r_r.self,
    ld_r_rraddr.self,
    ld_rraddr_n.self,
    ld_rraddr_r.self,
    ldd_a_hladdr.self,
    ldd_hladdr_a.self,
    ldh_a_ccaddr.self,
    ldh_ccaddr_a.self,
    ldi_a_hladdr.self,
    ldi_hladdr_a.self,

    // 16-bit loads
    ld_rr_nn.self,
    ld_sp_hl.self,
    pop_rr.self,
    push_rr.self,
  ]

  static let instructionEmulators: [InstructionEmulator] = {
    return LR35902.InstructionSet.allSpecs().map { spec in
      let instructions = instructionEmulatorFactories.compactMap { $0.init(spec: spec) }
      precondition(instructions.count <= 1)
      if let instruction = instructions.first {
        return instruction
      } else {
        return not_implemented(spec: spec)
      }
    }
  }()

  final class not_implemented: InstructionEmulator {
    init(spec: LR35902.Instruction.Spec) {}

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCodeResult {
      fatalError("Not yet implemented")
    }
  }

}
