import Foundation

import LR35902

protocol InstructionEmulatorInitializable: class {
  init?(spec: LR35902.Instruction.Spec)
}

protocol InstructionEmulator: class {
  func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation)
}

extension LR35902 {
  final class Emulation {}
}

extension InstructionEmulator {
  func read(address: LR35902.Address?, from memory: TraceableMemory) -> UInt8? {
    guard let address: LR35902.Address = address else {
      return nil
    }
    return memory.read(from: address)
  }

  func passesCondition(cnd: LR35902.Instruction.Condition?, cpu: LR35902) -> Bool? {
    switch cnd {
    case .none:      return true

    case .some(.c):  return  cpu.fcarry
    case .some(.nc):
      guard let fcarry = cpu.fcarry else {
        return nil
      }
      return !fcarry

    case .some(.z):  return  cpu.fzero
    case .some(.nz):
      guard let fzero = cpu.fzero else {
        return nil
      }
      return !fzero
    }
  }
}

// MARK: - Additions

extension InstructionEmulator {
  /** Adds 8-bit value to cpu.a. */
  func addConsideringCarry(cpu: LR35902, value: UInt8?) {
    cpu.fsubtract = false
    guard let fcarry = cpu.fcarry else {
      cpu.a = nil
      cpu.fzero = nil
      cpu.fcarry = nil
      cpu.fhalfcarry = nil
      return
    }
    if fcarry {
      add(cpu: cpu, value: value, carry: 1)
    } else {
      add(cpu: cpu, value: value, carry: 0)
    }
  }

  /** Adds 8-bit value to cpu.a. */
  func addNoCarry(cpu: LR35902, value: UInt8?) {
    cpu.fsubtract = false
    add(cpu: cpu, value: value, carry: 0)
  }

  /** Adds 8-bit value and a carry to cpu.a. */
  private func addWithCarry(cpu: LR35902, value: UInt8?) {
    cpu.fsubtract = false
    add(cpu: cpu, value: value, carry: 1)
  }

  private func add(cpu: LR35902, value: UInt8?, carry: UInt16) {
    guard let a = cpu.a,
          let value = value else {
      cpu.a = nil
      cpu.fzero = nil
      cpu.fcarry = nil
      cpu.fhalfcarry = nil
      return
    }
    let wideA = UInt16(truncatingIfNeeded: a)
    let wideVal = UInt16(truncatingIfNeeded: value)

    let halfResult: UInt16 = (wideA & 0xf) + (wideVal & 0xf) + carry
    let fullResult: UInt16 = wideA + wideVal + carry

    cpu.a = UInt8(truncatingIfNeeded: fullResult)
    cpu.fzero = cpu.a == 0
    cpu.fcarry = fullResult > 0xff
    cpu.fhalfcarry = halfResult > 0xf
  }
}

// MARK: - Subtractions

extension InstructionEmulator {
  /** Subtracts an 8-bit value from cpu.a. */
  func subConsideringCarry(cpu: LR35902, value: UInt8?) {
    cpu.fsubtract = true
    guard let fcarry = cpu.fcarry else {
      cpu.a = nil
      cpu.fzero = nil
      cpu.fcarry = nil
      cpu.fhalfcarry = nil
      return
    }
    if fcarry {
      sub(cpu: cpu, value: value, carry: 1)
    } else {
      sub(cpu: cpu, value: value, carry: 0)
    }
  }

  /** Subtracts an 8-bit value from cpu.a. */
  func subNoCarry(cpu: LR35902, value: UInt8?) {
    cpu.fsubtract = true
    sub(cpu: cpu, value: value, carry: 0)
  }

  /** Subtracts an 8-bit value and a carry from cpu.a. */
  private func subWithCarry(cpu: LR35902, value: UInt8?) {
    cpu.fsubtract = true
    sub(cpu: cpu, value: value, carry: 1)
  }

  private func sub(cpu: LR35902, value: UInt8?, carry: UInt16) {
    guard let a = cpu.a,
          let value = value else {
      cpu.a = nil
      cpu.fzero = nil
      cpu.fcarry = nil
      cpu.fhalfcarry = nil
      return
    }

    let wideA = UInt16(truncatingIfNeeded: a)
    let wideVal = UInt16(truncatingIfNeeded: value)

    let halfResult: UInt16 = (wideA & 0xf) &- (wideVal & 0xf) &- carry
    let fullResult: UInt16 = wideA &- wideVal &- carry

    cpu.a = UInt8(truncatingIfNeeded: fullResult)
    cpu.fzero = cpu.a == 0
    cpu.fcarry = fullResult > 0xff
    cpu.fhalfcarry = halfResult > 0xf
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
    adc_hladdr.self,
    adc_n.self,
    adc_r.self,
    add_a_hladdr.self,
    add_a_n.self,
    add_a_r.self,
    add_hl_rr.self,
    add_sp_n.self,
    dec_hladdr.self,
    dec_r.self,
    dec_rr.self,
    inc_hladdr.self,
    inc_r.self,
    inc_rr.self,
    sbc_hladdr.self,
    sbc_n.self,
    sbc_r.self,
    sub_a_hladdr.self,
    sub_a_n.self,
    sub_a_r.self,

    // Bit manipulation
    bit_b_hladdr.self,
    bit_b_r.self,
    daa.self,
    cpl.self,
    res_b_hladdr.self,
    res_b_r.self,
    rl_hladdr.self,
    rl_r.self,
    rla.self,
    rlc_hladdr.self,
    rlc_r.self,
    rlca.self,
    rr_hladdr.self,
    rr_r.self,
    rra.self,
    rrc_hladdr.self,
    rrc_r.self,
    rrca.self,
    set_b_hladdr.self,
    set_b_r.self,
    sla_hladdr.self,
    sla_r.self,
    sra_hladdr.self,
    sra_r.self,
    srl_hladdr.self,
    srl_r.self,
    swap_hladdr.self,
    swap_r.self,

    // Control flow
    call_cnd_nn.self,
    halt.self,
    jp_cnd_nn.self,
    jp_hl.self,
    jr_cnd_nn.self,
    nop.self,
    ret.self,
    ret_cnd.self,
    reti.self,
    rst_n.self,
    stop.self,

    // Interrupts
    di.self,
    ei.self,

    // 8-bit loads
    ld_a_ffnnaddr.self,
    ld_a_nnaddr.self,
    ld_ffnnaddr_a.self,
    ld_hl_spsimm8.self,
    ld_nnaddr_a.self,
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
    ld_nnaddr_sp.self,
    ld_rr_nn.self,
    ld_sp_hl.self,
    pop_rr.self,
    push_rr.self,

    // Logic
    and_hladdr.self,
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

    // Miscellaneous
    ccf.self,
    scf.self,
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

    func emulate(cpu: LR35902, memory: TraceableMemory, sourceLocation: Gameboy.SourceLocation) {
      fatalError("Not yet implemented: \(spec)")
    }

    private let spec: LR35902.Instruction.Spec
  }

}
