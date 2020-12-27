import Foundation

// References:
// - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
// - https://gekkio.fi/files/gb-docs/gbctr.pdf

extension LR35902.InstructionSet {
  static func microcode(for spec: LR35902.Instruction.Spec, sourceLocation: Disassembler.SourceLocation) -> LR35902.MachineInstruction.MicroCode {
    let registers8 = LR35902.Instruction.Numeric.registers8
    let registers16 = LR35902.Instruction.Numeric.registers16
    let registersAddr = LR35902.Instruction.Numeric.registersAddr

    let evaluateConditional: (LR35902.Instruction.Condition?, LR35902) -> LR35902.MachineInstruction.MicroCodeResult = { cnd, cpu in
      switch cnd {
      case .none:
        return .continueExecution
      case .some(.c):
        if cpu.fcarry {
          return .continueExecution
        } else {
          return .fetchNext
        }
      case .some(.nc):
        if !cpu.fcarry {
          return .continueExecution
        } else {
          return .fetchNext
        }
      case .some(.z):
        if cpu.fzero {
          return .continueExecution
        } else {
          return .fetchNext
        }
      case .some(.nz):
        if !cpu.fzero {
          return .continueExecution
        } else {
          return .fetchNext
        }
      }
    }

    switch spec {
    // ld r, r'
    case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
      return { (cpu, memory, cycle) in
        cpu[dst] = cpu[src] as UInt8
        cpu.registerTraces[dst] = cpu.registerTraces[src]
        return .fetchNext
      }

    // ld r, n
    case .ld(let dst, .imm8) where registers8.contains(dst):
      var immediate: UInt8 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          immediate = UInt8(memory.read(from: cpu.pc))
          cpu.pc += 1
          return .continueExecution
        }
        cpu[dst] = immediate
        cpu.registerTraces[dst] = .init(sourceLocation: sourceLocation)
        return .fetchNext
      }

    // ld r, (rr)
    case .ld(let dst, let src) where registers8.contains(dst) && registersAddr.contains(src):
      var value: UInt8 = 0

      return { (cpu, memory, cycle) in
        if cycle == 1 {
          let address = cpu[src] as UInt16
          value = UInt8(memory.read(from: address))
          cpu.registerTraces[dst] = .init(sourceLocation: sourceLocation, loadAddress: address)
          return .continueExecution
        }
        cpu[dst] = value
        return .fetchNext
      }

    // ld (rr), r
    case .ld(let dst, let src) where registersAddr.contains(dst) && registers8.contains(src):
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          memory.write(cpu[src], to: cpu[dst])
          return .continueExecution
        }
        return .fetchNext
      }

    // ld (rr), n
    case .ld(let dst, .imm8) where registersAddr.contains(dst):
      var immediate: UInt8 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          immediate = UInt8(memory.read(from: cpu.pc))
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          memory.write(immediate, to: cpu[dst])
          return .continueExecution
        }
        return .fetchNext
      }

    // ld a, (nn)
    case .ld(.a, .imm16addr):
      var immediate: UInt16 = 0
      var value: UInt8 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.pc))
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          immediate |= UInt16(memory.read(from: cpu.pc)) << 8
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 3 {
          value = memory.read(from: immediate)
          return .continueExecution
        }
        cpu.a = value
        cpu.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: immediate)
        return .fetchNext
      }

    // ld (nn), a
    case .ld(.imm16addr, .a):
      var immediate: UInt16 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.pc))
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          immediate |= UInt16(memory.read(from: cpu.pc)) << 8
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 3 {
          memory.write(cpu.a, to: immediate)
          return .continueExecution
        }
        return .fetchNext
      }

    // ldh a, (c)
    case .ld(.a, .ffccaddr):
      var value: UInt8 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          let address = UInt16(0xFF00) | UInt16(cpu.c)
          value = memory.read(from: address)
          cpu.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: address)
          return .continueExecution
        }
        cpu.a = value
        return .fetchNext
      }

    // ldh (c), a
    case .ld(.ffccaddr, .a):
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          let address = UInt16(0xFF00) | UInt16(cpu.c)
          memory.write(cpu.a, to: address)
          return .continueExecution
        }
        return .fetchNext
      }

    // ldh a, (n)
    case .ld(.a, .ffimm8addr):
      var immediate: UInt16 = 0
      var value: UInt8 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.pc))
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          let address = UInt16(0xFF00) | UInt16(immediate)
          value = memory.read(from: address)
          cpu.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: address)
          return .continueExecution
        }
        cpu.a = value
        return .fetchNext
      }

    // ldh (n), a
    case .ld(.ffimm8addr, .a):
      var immediate: UInt16 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.pc))
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          let address = UInt16(0xFF00) | UInt16(immediate)
          memory.write(cpu.a, to: address)
          return .continueExecution
        }
        return .fetchNext
      }

    // ld a, (hl-)
    case .ldd(.a, .hladdr):
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          cpu.a = memory.read(from: cpu.hl)
          cpu.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: cpu.hl)
          return .continueExecution
        }
        cpu.hl -= 1
        return .fetchNext
      }

    // ld (hl-), a
    case .ldd(.hladdr, .a):
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          memory.write(cpu.a, to: cpu.hl)
          return .continueExecution
        }
        cpu.hl -= 1
        return .fetchNext
      }

    // ld a, (hl+)
    case .ldi(.a, .hladdr):
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          cpu.a = memory.read(from: cpu.hl)
          cpu.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: cpu.hl)
          return .continueExecution
        }
        cpu.hl += 1
        return .fetchNext
      }

    // ld (hl+), a
    case .ldi(.hladdr, .a):
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          memory.write(cpu.a, to: cpu.hl)
          return .continueExecution
        }
        cpu.hl += 1
        return .fetchNext
      }

    // ld rr, nn
    case .ld(let dst, .imm16) where registers16.contains(dst):
      var immediate: UInt16 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.pc))
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          immediate |= UInt16(memory.read(from: cpu.pc)) << 8
          cpu.pc += 1
          return .continueExecution
        }

        cpu[dst] = immediate
        cpu.registerTraces[dst] = .init(
          sourceLocation: sourceLocation,
          loadAddress: immediate
        )
        return .fetchNext
      }

    // ld (nn), sp
    case .ld(.imm16addr, .sp):
      var immediate: UInt16 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.pc))
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          immediate |= UInt16(memory.read(from: cpu.pc)) << 8
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 3 {
          memory.write(UInt8(cpu.sp & 0x00FF), to: immediate)
          return .continueExecution
        }
        if cycle == 4 {
          memory.write(UInt8((cpu.sp & 0xFF00) >> 8), to: immediate + 1)
          return .continueExecution
        }
        return .fetchNext
      }

    // ld sp, hl
    case .ld(.sp, .hl):
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          cpu.sp = cpu.hl
          cpu.registerTraces[.sp] = cpu.registerTraces[.hl]
          return .continueExecution
        }
        return .fetchNext
      }

    // push rr
    case .push(let src) where registers16.contains(src):
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          cpu.sp -= 1
          return .continueExecution
        }
        if cycle == 2 {
          memory.write(UInt8(((cpu[src] as UInt16) & 0xFF00) >> 8), to: cpu.sp)
          cpu.sp -= 1
          return .continueExecution
        }
        if cycle == 3 {
          memory.write(UInt8((cpu[src] as UInt16) & 0x00FF), to: cpu.sp)
          return .continueExecution
        }
        return .fetchNext
      }

    // pop rr
    case .pop(let dst) where registers16.contains(dst):
      var value: UInt16 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          cpu.registerTraces[dst] = .init(
            sourceLocation: sourceLocation,
            loadAddress: cpu.sp
          )

          value = UInt16(memory.read(from: cpu.sp))
          cpu.sp += 1
          return .continueExecution
        }
        if cycle == 2 {
          value |= UInt16(memory.read(from: cpu.sp)) << 8
          cpu.sp += 1
          return .continueExecution
        }
        cpu[dst] = value
        return .fetchNext
      }

    // jp nn
    // jp cc, nn
    case .jp(let cnd, .imm16):
      var immediate: UInt16 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.pc))
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          immediate |= UInt16(memory.read(from: cpu.pc)) << 8
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 3 {
          return evaluateConditional(cnd, cpu)
        }
        cpu.pc = immediate
        return .fetchNext
      }

    // jp hl
    case .jp(nil, .hl):
      return { (cpu, memory, cycle) in
        cpu.pc = cpu.hl
        return .fetchNext
      }

    // jr cc, e
    case .jr(let cnd, .simm8):
      var immediate: Int8 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          immediate = Int8(bitPattern: memory.read(from: cpu.pc))
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          return evaluateConditional(cnd, cpu)
        }
        cpu.pc = cpu.pc.advanced(by: Int(immediate))
        return .fetchNext
      }

    // call nn
    // call cc, nn
    case .call(let cnd, .imm16):
      var immediate: UInt16 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.pc))
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          immediate |= UInt16(memory.read(from: cpu.pc)) << 8
          cpu.pc += 1
          return .continueExecution
        }
        if cycle == 3 {
          return evaluateConditional(cnd, cpu)
        }
        if cycle == 4 {
          cpu.sp -= 1
          memory.write(UInt8((cpu.pc & 0xFF00) >> 8), to: cpu.sp)
          return .continueExecution
        }
        if cycle == 5 {
          cpu.sp -= 1
          memory.write(UInt8(cpu.pc & 0x00FF), to: cpu.sp)
          return .continueExecution
        }
        cpu.pc = immediate
        return .fetchNext
      }

    // ret
    // ret cc
    case .ret(let cnd):
      var pc: UInt16 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          return evaluateConditional(cnd, cpu)
        }
        if cycle == 2 {
          pc = UInt16(memory.read(from: cpu.sp))
          cpu.sp += 1
          return .continueExecution
        }
        if cycle == 3 {
          pc |= UInt16(memory.read(from: cpu.sp)) << 8
          cpu.sp += 1
          return .continueExecution
        }
        cpu.pc = pc
        return .fetchNext
      }

    // reti
    case .reti:
      var pc: UInt16 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          pc = UInt16(memory.read(from: cpu.sp))
          cpu.sp += 1
          return .continueExecution
        }
        if cycle == 2 {
          pc |= UInt16(memory.read(from: cpu.sp)) << 8
          cpu.sp += 1
          return .continueExecution
        }
        if cycle == 3 {
          cpu.ime = true
          return .continueExecution
        }
        cpu.pc = pc
        return .fetchNext
      }

    // res b, r
    case .cb(.res(let bit, let register)) where registers8.contains(register):
      return { (cpu, memory, cycle) in
        cpu[register] = cpu[register] & ~(UInt8(1) << bit.rawValue)
        return .fetchNext
      }

    // cp n
    case .cp(.imm8):
      var immediate: UInt8 = 0
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          immediate = memory.read(from: cpu.pc)
          cpu.pc += 1
          return .continueExecution
        }

        cpu.fsubtract = true
        let result = cpu.a.subtractingReportingOverflow(immediate)
        cpu.fzero = result.partialValue == 0
        cpu.fcarry = result.overflow
        cpu.fhalfcarry = (cpu.a & 0x0f) < (immediate & 0x0f)

        return .fetchNext
      }

    // inc r
    case .inc(let register) where registers8.contains(register):
      return { (cpu, memory, cycle) in
        let originalValue = cpu[register] as UInt8
        let result = originalValue.addingReportingOverflow(1)
        cpu.fzero = result.partialValue == 0
        cpu.fhalfcarry = (((originalValue & 0x0f) + 1) & 0x10) > 0
        cpu.fsubtract = false
        cpu[register] = result.partialValue
        return .fetchNext
      }

    // dec r
    case .dec(let register) where registers8.contains(register):
      return { (cpu, memory, cycle) in
        let originalValue = cpu[register] as UInt8
        let result = originalValue.subtractingReportingOverflow(1)
        cpu.fzero = result.partialValue == 0
        cpu.fhalfcarry = (originalValue & 0x0f) == 0
        cpu.fsubtract = true
        cpu[register] = result.partialValue
        return .fetchNext
      }

    // inc rr
    case .inc(let register) where registers16.contains(register):
      return { (cpu, memory, cycle) in
        if cycle == 1 {
          return .continueExecution
        }
        cpu[register] = (cpu[register] as UInt16).addingReportingOverflow(1).partialValue
        return .fetchNext
      }

    // di
    case .di:
      return { (cpu, memory, cycle) in
        cpu.ime = false
        cpu.imeScheduledCyclesRemaining = 0
        return .fetchNext
      }

    // ei
    case .ei:
      return { (cpu, memory, cycle) in
        // IME will be enabled after the next machine cycle, so we set up a counter to track that delay.
        cpu.imeScheduledCyclesRemaining = 2
        return .fetchNext
      }

    case .nop:
      return { _, _, _ in .fetchNext }

    case .prefix:
      return { _, _, _ in .fetchNext }

    default:
      preconditionFailure("Unhandled specification: \(spec)")
    }
  }
}

extension LR35902 {
  /** Advances the CPU by one machine cycle. */
  public func advance(memory: inout AddressableMemory) -> LR35902 {
    // https://gekkio.fi/files/gb-docs/gbctr.pdf
    var mutation = self

    let nextAction: MachineInstruction.MicroCodeResult
    if let microcode = machineInstruction.loaded?.microcode {
      mutation.machineInstruction.cycle += 1
      nextAction = microcode(&mutation, &memory, mutation.machineInstruction.cycle)
    } else {
      nextAction = .fetchNext
    }

    // The LR35902's fetch/execute overlap behavior means we load the next opcode on the same machine cycle as the
    // last instruction's microcode execution.
    if nextAction == .fetchNext {
      var sourceLocation = Disassembler.sourceLocation(for: mutation.pc, in: mutation.bank)
      let tableIndex = Int(memory.read(from: mutation.pc))
      mutation.pc += 1
      let loadedSpec: Instruction.Spec
      if let loaded = mutation.machineInstruction.loaded,
         let prefixTable = InstructionSet.prefixTables[loaded.spec] {
        sourceLocation = loaded.sourceLocation
        loadedSpec = prefixTable[tableIndex]
      } else {
        loadedSpec = InstructionSet.table[tableIndex]
      }
      mutation.machineInstruction = .init(spec: loadedSpec, sourceLocation: sourceLocation)
    }

    return mutation
  }
}

extension Gameboy {
  /** Advances the emulation by one machine cycle. */
  public func advance() -> Gameboy {
    var mutated = self
    mutated.cpu = cpu.advance(memory: &mutated.memory)
    mutated.lcdController = lcdController.advance()

    // TODO: Verify this timing as I'm not confident it's being evaluated at the correct location.
    if mutated.cpu.imeScheduledCyclesRemaining > 0 {
      mutated.cpu.imeScheduledCyclesRemaining -= 1
      if mutated.cpu.imeScheduledCyclesRemaining <= 0 {
        mutated.cpu.ime = true
        mutated.cpu.imeScheduledCyclesRemaining = 0
      }
    }
    return mutated
  }

  /** Advances the emulation by one instruction. */
  public func advanceInstruction() -> Gameboy {
    var mutated = self
    if mutated.cpu.machineInstruction.loaded == nil {
      mutated = mutated.advance()
    }
    if let sourceLocation = mutated.cpu.machineInstruction.loaded?.sourceLocation {
      while sourceLocation == mutated.cpu.machineInstruction.loaded?.sourceLocation {
        mutated = mutated.advance()
      }
    }
    return mutated
  }
}
