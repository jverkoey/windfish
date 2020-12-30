import Foundation

// References:
// - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
// - https://gekkio.fi/files/gb-docs/gbctr.pdf

extension LR35902.InstructionSet {

  static let microcodes: [SpecType: LR35902.MachineInstruction.MicroCode] = {
    var microcodes: [SpecType: LR35902.MachineInstruction.MicroCode] = [:]
    allSpecs().forEach { spec in
      microcodes[spec] = microcode(for: spec)
    }
    return microcodes
  }()

  // TODO: Cache the results of this method per spec because it's currently the performance bottleneck. Should be a
  // simple matter of building a lookup table of microcode blocks that can accept sourceLocation as a parameter for
  // tracing. Tracing arguably could even be moved elsewhere to remove one layer of indirection.
  static func microcode(for spec: LR35902.Instruction.Spec) -> LR35902.MachineInstruction.MicroCode? {
    let registers8 = LR35902.Instruction.Numeric.registers8
    let registers16 = LR35902.Instruction.Numeric.registers16
    let registersAddr = LR35902.Instruction.Numeric.registersAddr

    let evaluateConditional: (LR35902.Instruction.Condition?, LR35902) -> LR35902.MachineInstruction.MicroCodeResult = { cnd, cpu in
      switch cnd {
      case .none:      return .continueExecution
      case .some(.c):  return  cpu.state.fcarry ? .continueExecution : .fetchNext
      case .some(.nc): return !cpu.state.fcarry ? .continueExecution : .fetchNext
      case .some(.z):  return  cpu.state.fzero ? .continueExecution : .fetchNext
      case .some(.nz): return !cpu.state.fzero ? .continueExecution : .fetchNext
      }
    }

    switch spec {
    // ld r, r'
    case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
      return { (cpu, memory, cycle, sourceLocation) in
        cpu.state[dst] = cpu.state[src] as UInt8
        cpu.state.registerTraces[dst] = cpu.state.registerTraces[src]
        return .fetchNext
      }

    // ld r, n
    case .ld(let dst, .imm8) where registers8.contains(dst):
      var immediate: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt8(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        cpu.state[dst] = immediate
        cpu.state.registerTraces[dst] = .init(sourceLocation: sourceLocation)
        return .fetchNext
      }

    // ld r, (rr)
    case .ld(let dst, let src) where registers8.contains(dst) && registersAddr.contains(src):
      var value: UInt8 = 0

      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          let address = cpu.state[src] as UInt16
          value = UInt8(memory.read(from: address))
          cpu.state.registerTraces[dst] = .init(sourceLocation: sourceLocation, loadAddress: address)
          return .continueExecution
        }
        cpu.state[dst] = value
        return .fetchNext
      }

    // ld (rr), r
    case .ld(let dst, let src) where registersAddr.contains(dst) && registers8.contains(src):
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          memory.write(cpu.state[src], to: cpu.state[dst])
          return .continueExecution
        }
        return .fetchNext
      }

    // ld (rr), n
    case .ld(let dst, .imm8) where registersAddr.contains(dst):
      var immediate: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt8(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          memory.write(immediate, to: cpu.state[dst])
          return .continueExecution
        }
        return .fetchNext
      }

    // ld a, (nn)
    case .ld(.a, .imm16addr):
      var immediate: UInt16 = 0
      var value: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          immediate |= UInt16(memory.read(from: cpu.state.pc)) << 8
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 3 {
          value = memory.read(from: immediate)
          return .continueExecution
        }
        cpu.state.a = value
        cpu.state.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: immediate)
        return .fetchNext
      }

    // ld (nn), a
    case .ld(.imm16addr, .a):
      var immediate: UInt16 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          immediate |= UInt16(memory.read(from: cpu.state.pc)) << 8
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 3 {
          memory.write(cpu.state.a, to: immediate)
          return .continueExecution
        }
        return .fetchNext
      }

    // ldh a, (c)
    case .ld(.a, .ffccaddr):
      var value: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          let address = UInt16(0xFF00) | UInt16(cpu.state.c)
          value = memory.read(from: address)
          cpu.state.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: address)
          return .continueExecution
        }
        cpu.state.a = value
        return .fetchNext
      }

    // ldh (c), a
    case .ld(.ffccaddr, .a):
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          let address = UInt16(0xFF00) | UInt16(cpu.state.c)
          memory.write(cpu.state.a, to: address)
          return .continueExecution
        }
        return .fetchNext
      }

    // ldh a, (n)
    case .ld(.a, .ffimm8addr):
      var immediate: UInt16 = 0
      var value: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          let address = UInt16(0xFF00) | UInt16(immediate)
          value = memory.read(from: address)
          cpu.state.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: address)
          return .continueExecution
        }
        cpu.state.a = value
        return .fetchNext
      }

    // ldh (n), a
    case .ld(.ffimm8addr, .a):
      var immediate: UInt16 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          let address = UInt16(0xFF00) | UInt16(immediate)
          memory.write(cpu.state.a, to: address)
          return .continueExecution
        }
        return .fetchNext
      }

    // ld a, (hl-)
    case .ldd(.a, .hladdr):
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          cpu.state.a = memory.read(from: cpu.state.hl)
          cpu.state.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: cpu.state.hl)
          return .continueExecution
        }
        cpu.state.hl -= 1
        return .fetchNext
      }

    // ld (hl-), a
    case .ldd(.hladdr, .a):
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          memory.write(cpu.state.a, to: cpu.state.hl)
          return .continueExecution
        }
        cpu.state.hl -= 1
        return .fetchNext
      }

    // ld a, (hl+)
    case .ldi(.a, .hladdr):
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          cpu.state.a = memory.read(from: cpu.state.hl)
          cpu.state.registerTraces[.a] = .init(sourceLocation: sourceLocation, loadAddress: cpu.state.hl)
          return .continueExecution
        }
        cpu.state.hl += 1
        return .fetchNext
      }

    // ld (hl+), a
    case .ldi(.hladdr, .a):
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          memory.write(cpu.state.a, to: cpu.state.hl)
          return .continueExecution
        }
        cpu.state.hl += 1
        return .fetchNext
      }

    // ld rr, nn
    case .ld(let dst, .imm16) where registers16.contains(dst):
      var immediate: UInt16 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          immediate |= UInt16(memory.read(from: cpu.state.pc)) << 8
          cpu.state.pc += 1
          return .continueExecution
        }

        cpu.state[dst] = immediate
        cpu.state.registerTraces[dst] = .init(
          sourceLocation: sourceLocation,
          loadAddress: immediate
        )
        return .fetchNext
      }

    // ld (nn), sp
    case .ld(.imm16addr, .sp):
      var immediate: UInt16 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          immediate |= UInt16(memory.read(from: cpu.state.pc)) << 8
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 3 {
          memory.write(UInt8(cpu.state.sp & 0x00FF), to: immediate)
          return .continueExecution
        }
        if cycle == 4 {
          memory.write(UInt8((cpu.state.sp & 0xFF00) >> 8), to: immediate + 1)
          return .continueExecution
        }
        return .fetchNext
      }

    // ld sp, hl
    case .ld(.sp, .hl):
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          cpu.state.sp = cpu.state.hl
          cpu.state.registerTraces[.sp] = cpu.state.registerTraces[.hl]
          return .continueExecution
        }
        return .fetchNext
      }

    // push rr
    case .push(let src) where registers16.contains(src):
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          cpu.state.sp -= 1
          return .continueExecution
        }
        if cycle == 2 {
          memory.write(UInt8(((cpu.state[src] as UInt16) & 0xFF00) >> 8), to: cpu.state.sp)
          cpu.state.sp -= 1
          return .continueExecution
        }
        if cycle == 3 {
          memory.write(UInt8((cpu.state[src] as UInt16) & 0x00FF), to: cpu.state.sp)
          return .continueExecution
        }
        return .fetchNext
      }

    // pop rr
    case .pop(let dst) where registers16.contains(dst):
      var value: UInt16 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          cpu.state.registerTraces[dst] = .init(
            sourceLocation: sourceLocation,
            loadAddress: cpu.state.sp
          )

          value = UInt16(memory.read(from: cpu.state.sp))
          cpu.state.sp += 1
          return .continueExecution
        }
        if cycle == 2 {
          value |= UInt16(memory.read(from: cpu.state.sp)) << 8
          cpu.state.sp += 1
          return .continueExecution
        }
        cpu.state[dst] = value
        return .fetchNext
      }

    // jp nn
    // jp cc, nn
    case .jp(let cnd, .imm16):
      var immediate: UInt16 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          immediate |= UInt16(memory.read(from: cpu.state.pc)) << 8
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 3 {
          return evaluateConditional(cnd, cpu)
        }
        cpu.state.pc = immediate
        return .fetchNext
      }

    // jp hl
    case .jp(nil, .hl):
      return { (cpu, memory, cycle, sourceLocation) in
        cpu.state.pc = cpu.state.hl
        return .fetchNext
      }

    // jr cc, e
    case .jr(let cnd, .simm8):
      var immediate: Int8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = Int8(bitPattern: memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          return evaluateConditional(cnd, cpu)
        }
        cpu.state.pc = cpu.state.pc.advanced(by: Int(immediate))
        return .fetchNext
      }

    // call nn
    // call cc, nn
    case .call(let cnd, .imm16):
      var immediate: UInt16 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt16(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 2 {
          immediate |= UInt16(memory.read(from: cpu.state.pc)) << 8
          cpu.state.pc += 1
          return .continueExecution
        }
        if cycle == 3 {
          return evaluateConditional(cnd, cpu)
        }
        if cycle == 4 {
          cpu.state.sp -= 1
          memory.write(UInt8((cpu.state.pc & 0xFF00) >> 8), to: cpu.state.sp)
          return .continueExecution
        }
        if cycle == 5 {
          cpu.state.sp -= 1
          memory.write(UInt8(cpu.state.pc & 0x00FF), to: cpu.state.sp)
          return .continueExecution
        }
        cpu.state.pc = immediate
        return .fetchNext
      }

    // rst n
    case .rst(let address):
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          return .continueExecution
        }
        if cycle == 2 {
          cpu.state.sp -= 1
          memory.write(UInt8((cpu.state.pc & 0xFF00) >> 8), to: cpu.state.sp)
          return .continueExecution
        }
        if cycle == 3 {
          cpu.state.sp -= 1
          memory.write(UInt8(cpu.state.pc & 0x00FF), to: cpu.state.sp)
          return .continueExecution
        }
        cpu.state.pc = LR35902.Address(address.rawValue)
        return .fetchNext
      }

    // ret
    // ret cc
    case .ret(let cnd):
      var pc: UInt16 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          return evaluateConditional(cnd, cpu)
        }
        if cycle == 2 {
          pc = UInt16(memory.read(from: cpu.state.sp))
          cpu.state.sp += 1
          return .continueExecution
        }
        if cycle == 3 {
          pc |= UInt16(memory.read(from: cpu.state.sp)) << 8
          cpu.state.sp += 1
          return .continueExecution
        }
        cpu.state.pc = pc
        return .fetchNext
      }

    // reti
    case .reti:
      var pc: UInt16 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          pc = UInt16(memory.read(from: cpu.state.sp))
          cpu.state.sp += 1
          return .continueExecution
        }
        if cycle == 2 {
          pc |= UInt16(memory.read(from: cpu.state.sp)) << 8
          cpu.state.sp += 1
          return .continueExecution
        }
        if cycle == 3 {
          cpu.state.ime = true
          return .continueExecution
        }
        cpu.state.pc = pc
        return .fetchNext
      }

    // set b, r
    case .cb(.set(let bit, let register)) where registers8.contains(register):  // TODO: Test me
      return { (cpu, memory, cycle, sourceLocation) in
        cpu.state[register] = cpu.state[register] | (UInt8(1) << bit.rawValue)
        return .fetchNext
      }

    // res b, r
    case .cb(.res(let bit, let register)) where registers8.contains(register):
      return { (cpu, memory, cycle, sourceLocation) in
        cpu.state[register] = cpu.state[register] & ~(UInt8(1) << bit.rawValue)
        return .fetchNext
      }

    // bit b, r
    case .cb(.bit(let bit, let register)) where registers8.contains(register):  // TODO: Test me
      return { (cpu, memory, cycle, sourceLocation) in
        cpu.state.fzero = (cpu.state[register] & (UInt8(1) << bit.rawValue)) == 0
        cpu.state.fsubtract = false
        cpu.state.fhalfcarry = true
        return .fetchNext
      }

    // bit b, [hl]
    case .cb(.bit(let bit, .hladdr)):  // TODO: Test me
      var value: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          value = memory.read(from: cpu.state.hl)
          return .continueExecution
        }
        if cycle == 2 {
          cpu.state.fzero = (value & (UInt8(1) << bit.rawValue)) == 0
          cpu.state.fsubtract = false
          cpu.state.fhalfcarry = true
          return .continueExecution
        }
        if cycle == 3 {
          memory.write(value, to: cpu.state.hl)
          return .continueExecution
        }
        return .fetchNext
      }

    // swap r
    case .cb(.swap(let register)) where registers8.contains(register):  // TODO: Test me
      return { (cpu, memory, cycle, sourceLocation) in
        let upperNibble: UInt8 = cpu.state[register] & 0xF0
        let lowerNibble: UInt8 = cpu.state[register] & 0x0F
        let result = (upperNibble >> 8) | (lowerNibble << 8)
        cpu.state[register] = result
        cpu.state.fzero = result == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = false
        cpu.state.fhalfcarry = false
        return .fetchNext
      }

    // sla r
    case .cb(.sla(let register)) where registers8.contains(register):  // TODO: Test me
      return { (cpu, memory, cycle, sourceLocation) in
        let result = (cpu.state[register] as UInt8).multipliedReportingOverflow(by: 2)
        cpu.state[register] = result.partialValue
        cpu.state.fzero = result.partialValue == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = result.overflow
        cpu.state.fhalfcarry = false
        return .fetchNext
      }

    // rl r
    case .cb(.rl(let register)) where registers8.contains(register):  // TODO: Test me
      return { (cpu, memory, cycle, sourceLocation) in
        let partialResult = (cpu.state[register] as UInt8).multipliedReportingOverflow(by: 2)
        let result = partialResult.partialValue | (partialResult.overflow ? 0x01 : 0)

        cpu.state.fzero = result == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = partialResult.overflow
        cpu.state.fhalfcarry = false

        cpu.state[register] = result

        return .fetchNext
      }

    // srl r
    case .cb(.srl(let register)) where registers8.contains(register):  // TODO: Test me
      return { (cpu, memory, cycle, sourceLocation) in
        let partialResult = (cpu.state[register] as UInt8).dividedReportingOverflow(by: 2)
        let result = partialResult.partialValue

        cpu.state.fzero = result == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = partialResult.overflow
        cpu.state.fhalfcarry = false

        cpu.state[register] = result

        return .fetchNext
      }

    // rlca
    case .rlca:  // TODO: Test me
      return { (cpu, memory, cycle, sourceLocation) in
        let partialResult = cpu.state.a.multipliedReportingOverflow(by: 2)
        let result = partialResult.partialValue | (partialResult.overflow ? 0x01 : 0)

        cpu.state.fzero = result == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = partialResult.overflow
        cpu.state.fhalfcarry = false

        cpu.state.a = result

        return .fetchNext
      }

    // rra
    case .rra:  // TODO: Test me
      return { (cpu, memory, cycle, sourceLocation) in
        let partialResult = cpu.state.a.dividedReportingOverflow(by: 2)
        let result = partialResult.partialValue | (cpu.state.fcarry ? 0b1000_0000 : 0)
        cpu.state.a = result
        cpu.state.fzero = result == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = partialResult.overflow
        cpu.state.fhalfcarry = false
        return .fetchNext
      }

    // rrca
    case .rrca:  // TODO: Test me
      return { (cpu, memory, cycle, sourceLocation) in
        let partialResult = cpu.state.a.dividedReportingOverflow(by: 2)
        let result = partialResult.partialValue | (partialResult.overflow ? 0b1000_0000 : 0)
        cpu.state.a = result
        cpu.state.fzero = result == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = partialResult.overflow
        cpu.state.fhalfcarry = false
        return .fetchNext
      }

    // cp n
    case .cp(.imm8):
      var immediate: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = memory.read(from: cpu.state.pc)
          cpu.state.pc += 1
          return .continueExecution
        }

        cpu.state.fsubtract = true
        let result = cpu.state.a.subtractingReportingOverflow(immediate)
        cpu.state.fzero = result.partialValue == 0
        cpu.state.fcarry = result.overflow
        cpu.state.fhalfcarry = (cpu.state.a & 0x0f) < (immediate & 0x0f)
        return .fetchNext
      }

    // cp r
    case .cp(let register) where registers8.contains(register):
      return { (cpu, memory, cycle, sourceLocation) in
        cpu.state.fsubtract = true
        let registerValue: UInt8 = cpu.state[register]
        let result = cpu.state.a.subtractingReportingOverflow(registerValue)
        cpu.state.fzero = result.partialValue == 0
        cpu.state.fcarry = result.overflow
        cpu.state.fhalfcarry = (cpu.state.a & 0x0f) < (registerValue & 0x0f)
        return .fetchNext
      }

    // cp [hl]
    case .cp(.hladdr):  // TODO: Test me
      var value: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          value = memory.read(from: cpu.state.hl)
          return .continueExecution
        }
        cpu.state.fsubtract = true
        let result = cpu.state.a.subtractingReportingOverflow(value)
        cpu.state.fzero = result.partialValue == 0
        cpu.state.fcarry = result.overflow
        cpu.state.fhalfcarry = (cpu.state.a & 0x0f) < (value & 0x0f)
        return .fetchNext
      }

    // inc r
    case .inc(let register) where registers8.contains(register):
      return { (cpu, memory, cycle, sourceLocation) in
        let originalValue = cpu.state[register] as UInt8
        let result = originalValue.addingReportingOverflow(1)
        cpu.state.fzero = result.partialValue == 0
        cpu.state.fhalfcarry = (((originalValue & 0x0f) + 1) & 0x10) > 0
        cpu.state.fsubtract = false
        cpu.state[register] = result.partialValue
        return .fetchNext
      }

    // inc [hl]
    case .inc(.hladdr):
      var value: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          value = memory.read(from: cpu.state.hl)
          return .continueExecution
        }
        if cycle == 2 {
          let result = value.addingReportingOverflow(1)
          cpu.state.fzero = result.partialValue == 0
          cpu.state.fhalfcarry = (((value & 0x0f) + 1) & 0x10) > 0
          cpu.state.fsubtract = false
          value = result.partialValue
          return .continueExecution
        }
        if cycle == 3 {
          memory.write(value, to: cpu.state.hl)
          return .continueExecution
        }
        return .fetchNext
      }

    // dec r
    case .dec(let register) where registers8.contains(register):
      return { (cpu, memory, cycle, sourceLocation) in
        let originalValue = cpu.state[register] as UInt8
        let result = originalValue.subtractingReportingOverflow(1)
        cpu.state.fzero = result.partialValue == 0
        cpu.state.fsubtract = true
        cpu.state.fhalfcarry = (originalValue & 0x0f) < (1 & 0x0f)
        cpu.state[register] = result.partialValue
        return .fetchNext
      }

    // dec [hl]
    case .dec(.hladdr):  // TODO: Test me
      var value: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          value = memory.read(from: cpu.state.hl)
          return .continueExecution
        }
        if cycle == 2 {
          let result = value.subtractingReportingOverflow(1)
          cpu.state.fzero = result.partialValue == 0
          cpu.state.fsubtract = true
          cpu.state.fhalfcarry = (value & 0x0f) < (1 & 0x0f)

          value = result.partialValue

          return .continueExecution
        }
        memory.write(value, to: cpu.state.hl)
        return .fetchNext
      }

    // dec rr
    case .dec(let register) where registers16.contains(register):
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          return .continueExecution
        }
        cpu.state[register] = (cpu.state[register] as UInt16).subtractingReportingOverflow(1).partialValue
        return .fetchNext
      }

    // sub r
    case .sub(.a, let register) where registers8.contains(register):  // TODO: Test me
      return { (cpu, memory, cycle, sourceLocation) in
        let originalValue = cpu.state.a
        let value = cpu.state[register] as UInt8
        let result = originalValue.subtractingReportingOverflow(value)
        cpu.state.fzero = result.partialValue == 0
        cpu.state.fsubtract = true
        cpu.state.fcarry = result.overflow
        cpu.state.fhalfcarry = (cpu.state.a & 0x0f) < (value & 0x0f)
        cpu.state.a = result.partialValue
        return .fetchNext
      }

    // sub n
    case .sub(.a, .imm8):
      var immediate: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt8(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        let originalValue = cpu.state.a
        let result = originalValue.subtractingReportingOverflow(immediate)
        cpu.state.fzero = result.partialValue == 0
        cpu.state.fsubtract = true
        cpu.state.fcarry = result.overflow
        cpu.state.fhalfcarry = (cpu.state.a & 0x0f) < (immediate & 0x0f)
        cpu.state.a = result.partialValue
        return .fetchNext
      }

    // sub n
    case .sbc(.imm8):  // TODO: Test me
      var immediate: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt8(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }

        immediate += cpu.state.fcarry ? 1 : 0

        let originalValue = cpu.state.a
        let result = originalValue.subtractingReportingOverflow(immediate)
        cpu.state.fzero = result.partialValue == 0
        cpu.state.fsubtract = true
        cpu.state.fcarry = result.overflow
        cpu.state.fhalfcarry = (cpu.state.a & 0x0f) < (immediate & 0x0f)
        cpu.state.a = result.partialValue
        return .fetchNext
      }

    // sub [hl]
    case .sub(.a, .hladdr):  // TODO: Test me
      var value: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          value = memory.read(from: cpu.state.hl)
          return .continueExecution
        }
        let originalValue = cpu.state.a
        let result = originalValue.subtractingReportingOverflow(value)
        cpu.state.fzero = result.partialValue == 0
        cpu.state.fsubtract = true
        cpu.state.fcarry = result.overflow
        cpu.state.fhalfcarry = (cpu.state.a & 0x0f) < (value & 0x0f)
        cpu.state.a = result.partialValue
        return .fetchNext
      }

    // inc rr
    case .inc(let register) where registers16.contains(register):
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          return .continueExecution
        }
        cpu.state[register] = (cpu.state[register] as UInt16).addingReportingOverflow(1).partialValue
        return .fetchNext
      }

    // di
    case .di:
      return { (cpu, memory, cycle, sourceLocation) in
        cpu.state.ime = false
        cpu.state.imeScheduledCyclesRemaining = 0
        return .fetchNext
      }

    // ei
    case .ei:
      return { (cpu, memory, cycle, sourceLocation) in
        // IME will be enabled after the next machine cycle, so we set up a counter to track that delay.
        cpu.state.imeScheduledCyclesRemaining = 2
        return .fetchNext
      }

    // or r
    case .or(let register) where registers8.contains(register):
      return { (cpu, memory, cycle, sourceLocation) in
        cpu.state.a |= cpu.state[register]
        cpu.state.fzero = cpu.state.a == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = false
        cpu.state.fhalfcarry = false
        return .fetchNext
      }

    // or n
    case .or(.imm8):  // TODO: Test me
      var immediate: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt8(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        cpu.state.a |= immediate
        cpu.state.fzero = cpu.state.a == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = false
        cpu.state.fhalfcarry = false
        return .fetchNext
      }

    // or [hl]
    case .or(.hladdr):
      var value: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          value = memory.read(from: cpu.state.hl)
          return .continueExecution
        }
        cpu.state.a |= value
        cpu.state.fzero = cpu.state.a == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = false
        cpu.state.fhalfcarry = false
        return .fetchNext
      }

    // xor r
    case .xor(let register) where registers8.contains(register):
      return { (cpu, memory, cycle, sourceLocation) in
        cpu.state.a ^= cpu.state[register]
        cpu.state.fzero = cpu.state.a == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = false
        cpu.state.fhalfcarry = false
        return .fetchNext
      }

    // xor [hl]
    case .xor(.hladdr):  // TODO: Test me
      var value: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          value = memory.read(from: cpu.state.hl)
          return .continueExecution
        }
        cpu.state.a ^= value
        cpu.state.fzero = cpu.state.a == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = false
        cpu.state.fhalfcarry = false
        return .fetchNext
      }

    // xor n
    case .xor(.imm8):  // TODO: Test me
      var immediate: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt8(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        cpu.state.a ^= immediate
        cpu.state.fzero = cpu.state.a == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = false
        cpu.state.fhalfcarry = false
        return .fetchNext
      }

    // and n
    case .and(.imm8):
      var immediate: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt8(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        cpu.state.a &= immediate
        cpu.state.fzero = cpu.state.a == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = false
        cpu.state.fhalfcarry = true
        return .fetchNext
      }

    // and r
    case .and(let register) where registers8.contains(register):
      return { (cpu, memory, cycle, sourceLocation) in
        cpu.state.a &= cpu.state[register]
        cpu.state.fzero = cpu.state.a == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = false
        cpu.state.fhalfcarry = true
        return .fetchNext
      }

    // add r
    case .add(.a, let register) where registers8.contains(register):  // TODO: Test me
      return { (cpu, memory, cycle, sourceLocation) in
        let originalValue = cpu.state.a
        let registerValue = cpu.state[register] as UInt8
        let result = originalValue.addingReportingOverflow(registerValue)

        cpu.state.fzero = result.partialValue == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = result.overflow
        cpu.state.fhalfcarry = (((originalValue & 0x0f) + (registerValue & 0x0f)) & 0x10) > 0

        cpu.state.a = result.partialValue

        return .fetchNext
      }

    // add n
    case .add(.a, .imm8):
      var immediate: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt8(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }
        let originalValue = cpu.state.a
        let result = originalValue.addingReportingOverflow(immediate)
        cpu.state.fzero = result.partialValue == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = result.overflow
        cpu.state.fhalfcarry = (((originalValue & 0x0f) + (immediate & 0x0f)) & 0x10) > 0
        cpu.state.a = result.partialValue
        return .fetchNext
      }

    // add a, [hl]
    case .add(.a, .hladdr):  // TODO: Test me.
      var value: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          value = memory.read(from: cpu.state.hl)
          return .continueExecution
        }
        let originalValue = cpu.state.a
        let result = originalValue.addingReportingOverflow(value)
        cpu.state.fzero = result.partialValue == 0
        cpu.state.fsubtract = false
        cpu.state.fcarry = result.overflow
        cpu.state.fhalfcarry = (((originalValue & 0x0f) + (value & 0x0f)) & 0x10) > 0
        cpu.state.a = result.partialValue
        return .fetchNext
      }

    // add hl, rr
    case .add(.hl, let src) where registers16.contains(src):
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          return .continueExecution
        }
        let originalValue = cpu.state.hl
        let sourceValue: UInt16 = cpu.state[src]
        let result = originalValue.addingReportingOverflow(sourceValue)
        cpu.state.fsubtract = false
        cpu.state.fcarry = result.overflow
        cpu.state.fhalfcarry = (((originalValue & 0x0fff) + (sourceValue & 0x0fff)) & 0x1000) > 0
        cpu.state.hl = result.partialValue
        return .fetchNext
      }

    // adc n
    case .adc(.imm8):  // TODO: Test me
      var immediate: UInt8 = 0
      return { (cpu, memory, cycle, sourceLocation) in
        if cycle == 1 {
          immediate = UInt8(memory.read(from: cpu.state.pc))
          cpu.state.pc += 1
          return .continueExecution
        }

        immediate += cpu.state.fcarry ? 1 : 0

        let originalValue = cpu.state.a
        let result = originalValue.subtractingReportingOverflow(immediate)
        cpu.state.fzero = result.partialValue == 0
        cpu.state.fsubtract = true
        cpu.state.fcarry = result.overflow
        cpu.state.fhalfcarry = (cpu.state.a & 0x0f) < (immediate & 0x0f)
        cpu.state.a = result.partialValue
        return .fetchNext
      }

    // cpl
    case .cpl:  // TODO: Test me
      return { (cpu, memory, cycle, sourceLocation) in
        cpu.state.a = ~cpu.state.a
        cpu.state.fsubtract = true
        cpu.state.fcarry = true
        return .fetchNext
      }

    case .halt:
      return { (cpu, memory, cycle, sourceLocation) in
        // TODO: Implement HALT bug behavior outlined in https://github.com/AntonioND/giibiiadvance/tree/master/docs
        cpu.state.halted = true
        return .fetchNext
      }

    case .nop:
      return { _, _, _, _ in .fetchNext }

    case .prefix:
      return { _, _, _, _ in .fetchPrefix }

    default:
      return nil
    }
  }
}

extension LR35902 {
  /** Advances the CPU by one machine cycle. */
  public func advance(memory: AddressableMemory) {
    // https://gekkio.fi/files/gb-docs/gbctr.pdf
    if state.isRunning() {
      // Execution phase
      if nextAction == .continueExecution, let loaded = state.machineInstruction.loaded {
        state.machineInstruction.cycle += 1
        nextAction = loaded.microcode(self, memory, state.machineInstruction.cycle, loaded.sourceLocation)
      } else {
        // No instruction was actually loaded into the CPU; let's switch to fetching one.
        nextAction = .fetchNext
      }
    }

    // The LR35902's fetch/execute overlap behavior means we load the next opcode on the same machine cycle as the
    // last instruction's microcode execution.
    if nextAction == .fetchNext || nextAction == .fetchPrefix {
      let interrupts = state.interruptFlag.intersection(state.interruptEnable)
      if nextAction == .fetchNext && !interrupts.isEmpty {
        // Interrupt phase
        state.halted = false

        let sourceLocation = memory.sourceLocation(from: state.pc)
        nextAction = .continueExecution
        state.machineInstruction = .init(spec: .interrupt(interrupts), sourceLocation: sourceLocation)

      } else if state.isRunning() {
        // Fetch phase
        var sourceLocation = memory.sourceLocation(from: state.pc)
        let tableIndex = Int(truncatingIfNeeded: memory.read(from: state.pc))
        state.pc += 1
        let loadedSpec: Instruction.Spec
        if let loaded = state.machineInstruction.loaded, let prefixTable = InstructionSet.prefixTables[loaded.spec] {
          // Finish loading the prefix instruction.
          sourceLocation = loaded.sourceLocation
          loadedSpec = prefixTable[tableIndex]
        } else {
          loadedSpec = InstructionSet.table[tableIndex]
        }
        nextAction = .continueExecution
        state.machineInstruction = .init(spec: loadedSpec, sourceLocation: sourceLocation)
      }
    }

    // TODO: Verify this timing as I'm not confident it's being evaluated at the correct location.
    if state.imeScheduledCyclesRemaining > 0 {
      state.imeScheduledCyclesRemaining -= 1
      if state.imeScheduledCyclesRemaining <= 0 {
        state.ime = true
        state.imeScheduledCyclesRemaining = 0
      }
    }
  }
}

extension Gameboy {
  /** Advances the emulation by one machine cycle. */
  public func advance() {
    // DMA controller is always able to access memory directly.
    dmaController.advance(memory: memory)

    let proxyMemory: AddressableMemory = dmaController.oamLocked ? dmaProxy : memory
    cpu.advance(memory: proxyMemory)
    lcdController.advance(memory: proxyMemory)
  }

  /** Advances the emulation by one instruction. */
  public func advanceInstruction() {
    if cpu.state.machineInstruction.loaded == nil {
      advance()
    }
    if let sourceLocation = cpu.state.machineInstruction.loaded?.sourceLocation {
      while sourceLocation == cpu.state.machineInstruction.loaded?.sourceLocation, !cpu.state.halted {
        advance()
      }
    }
  }
}
