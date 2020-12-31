import Foundation

protocol InstructionEmulatorInitializable: class {
  init?(spec: LR35902.Instruction.Spec)
}

protocol InstructionEmulator: class {
  func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult
}

extension LR35902 {
  final class Emulation {}
}

extension InstructionEmulator {
  func checkConditional(cnd: LR35902.Instruction.Condition?, cpu: LR35902) -> LR35902.Emulation.EmulationResult {
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
  enum EmulationResult {
    case continueExecution
    case fetchNext
    case fetchPrefix
  }

  private static var instructionEmulatorFactories: [InstructionEmulatorInitializable.Type] = [
    // Arithmetic
    adc_n.self,
    add_a_hladdr.self,
    add_a_n.self,
    add_a_r.self,
    add_hl_rr.self,
    dec_hladdr.self,
    dec_r.self,
    dec_rr.self,
    inc_hladdr.self,
    inc_r.self,
    inc_rr.self,
    sbc_n.self,
    sub_a_hladdr.self,
    sub_a_n.self,
    sub_a_r.self,

    // Bit manipulation
    bit_b_hladdr.self,
    bit_b_r.self,
    cpl.self,
    rl_r.self,
    rlca.self,
    rra.self,
    rrc_r.self,
    rrca.self,
    res_b_r.self,
    set_b_r.self,
    sla_r.self,
    srl_r.self,
    swap_r.self,

    // Control flow
    call_cnd_nn.self,
    halt.self,
    jp_cnd_nn.self,
    jp_hl.self,
    jr_cnd_nn.self,
    nop.self,
    ret_cnd.self,
    reti.self,
    rst_n.self,

    // Interrupts
    di.self,
    ei.self,

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

    // Logic
    and_n.self,
    and_r.self,
    cp_hladdr.self,
    cp_n.self,
    cp_r.self,
    or_hladdr.self,
    or_n.self,
    or_r.self,
    xor_hladdr.self,
    xor_n.self,
    xor_r.self,

    // Internal
    prefix.self,
  ]

  static let instructionEmulators: [InstructionEmulator] = {
    return LR35902.InstructionSet.allSpecs().map { spec in
      let instructions = instructionEmulatorFactories.compactMap { $0.init(spec: spec) as? InstructionEmulator }
      precondition(instructions.count <= 1)
      if let instruction = instructions.first {
        return instruction
      } else {
        return not_implemented(spec: spec)
      }
    }
  }()

  final class not_implemented: InstructionEmulator, InstructionEmulatorInitializable {
    init(spec: LR35902.Instruction.Spec) {
      self.spec = spec
    }

    func advance(cpu: LR35902, memory: AddressableMemory, cycle: Int, sourceLocation: Disassembler.SourceLocation) -> LR35902.Emulation.EmulationResult {
      fatalError("Not yet implemented: \(spec)")
    }

    private let spec: LR35902.Instruction.Spec
  }

}
