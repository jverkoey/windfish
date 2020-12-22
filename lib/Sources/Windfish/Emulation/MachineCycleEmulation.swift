import Foundation

extension LR35902.InstructionSet {
  static func microcode(for spec: LR35902.Instruction.Spec) -> LR35902.MachineInstruction.MicroCode {
    let registers8 = LR35902.Instruction.Numeric.registers8
    let registers16 = LR35902.Instruction.Numeric.registers16

    switch spec {
    case .ld(let dst, .imm16) where registers16.contains(dst):
      var immediate: UInt16 = 0
      return [
        { (cpu, memory) in
          immediate = UInt16(memory.read(from: cpu.pc))
          cpu.pc += 1
        },
        { (cpu, memory) in
          immediate |= UInt16(memory.read(from: cpu.pc)) << 8
          cpu.pc += 1
        },
        { (cpu, memory) in
          cpu[dst] = immediate

          // TODO: Move the trace registration out of the microcode.
          cpu.registerTraces[dst] = .init(sourceLocation: Gameboy.Cartridge.location(for: cpu.pc - 3, in: cpu.bank)!,
                                          loadAddress: immediate)
        },
      ]

    case .nop:
      return []
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

    if machineInstruction.cycle < machineInstruction.microcode.count {
      machineInstruction.microcode[machineInstruction.cycle](&mutation, &memory)
      mutation.machineInstruction.cycle += 1
    }

    // The LR35902's fetch/execute overlap behavior means we load the next opcode on the same machine cycle as the
    // last instruction's microcode execution.
    if machineInstruction.cycle == machineInstruction.microcode.count {
      let tableIndex = Int(memory.read(from: pc))
      mutation.pc += 1
      let loadedSpec: Instruction.Spec
      if let spec = mutation.machineInstruction.spec,
          let prefixTable = InstructionSet.prefixTables[spec] {
        loadedSpec = prefixTable[tableIndex]
      } else {
        loadedSpec = InstructionSet.table[tableIndex]
      }
      mutation.machineInstruction = .init(spec: loadedSpec, microcode: InstructionSet.microcode(for: loadedSpec))
    }

    return mutation
  }
}
