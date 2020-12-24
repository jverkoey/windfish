import Foundation

extension LR35902.InstructionSet {
  static func microcode(for spec: LR35902.Instruction.Spec) -> LR35902.MachineInstruction.MicroCode {
    let registers8 = LR35902.Instruction.Numeric.registers8
    let registers16 = LR35902.Instruction.Numeric.registers16
    let registersAddr = LR35902.Instruction.Numeric.registersAddr

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
        cpu.registerTraces[dst] = .init(sourceLocation: cpu.machineInstruction.sourceLocation)
        return .fetchNext
      }

    // ld r, (rr)
    case .ld(let dst, let src) where registers8.contains(dst) && registersAddr.contains(src):
      var value: UInt8 = 0

      return { (cpu, memory, cycle) in
        if cycle == 1 {
          let address = cpu[src] as UInt16
          value = UInt8(memory.read(from: address))
          cpu.registerTraces[dst] = .init(sourceLocation: cpu.machineInstruction.sourceLocation, loadAddress: address)
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
        cpu.registerTraces[.a] = .init(sourceLocation: cpu.machineInstruction.sourceLocation, loadAddress: immediate)
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
          cpu.registerTraces[.a] = .init(sourceLocation: cpu.machineInstruction.sourceLocation, loadAddress: address)
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
          cpu.registerTraces[.a] = .init(sourceLocation: cpu.machineInstruction.sourceLocation, loadAddress: address)
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
          cpu.registerTraces[.a] = .init(sourceLocation: cpu.machineInstruction.sourceLocation, loadAddress: cpu.hl)
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
          cpu.registerTraces[.a] = .init(sourceLocation: cpu.machineInstruction.sourceLocation, loadAddress: cpu.hl)
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
          sourceLocation: cpu.machineInstruction.sourceLocation,
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

    case .nop:
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
    if let microcode = machineInstruction.microcode {
      mutation.machineInstruction.cycle += 1
      nextAction = microcode(&mutation, &memory, mutation.machineInstruction.cycle)
    } else {
      nextAction = .fetchNext
    }

    // The LR35902's fetch/execute overlap behavior means we load the next opcode on the same machine cycle as the
    // last instruction's microcode execution.
    if nextAction == .fetchNext {
      let sourceLocation = Gameboy.Cartridge.location(for: pc, in: bank)!
      let tableIndex = Int(memory.read(from: pc))
      mutation.pc += 1
      let loadedSpec: Instruction.Spec
      if let spec = mutation.machineInstruction.spec,
          let prefixTable = InstructionSet.prefixTables[spec] {
        loadedSpec = prefixTable[tableIndex]
      } else {
        loadedSpec = InstructionSet.table[tableIndex]
      }
      mutation.machineInstruction = .init(spec: loadedSpec, sourceLocation: sourceLocation)
    }

    return mutation
  }
}
