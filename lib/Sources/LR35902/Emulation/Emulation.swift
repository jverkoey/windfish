import Foundation

extension LR35902.CPUState {
  /**
   Emulates the given instruction and returns the advanced CPU state.

   - Parameter followControlFlow: If enabled, emulation will follow any transfers of control flow. Otherwise, control
   flow changes will be ignored and the instruction will be immediately stepped over.
   */
  public func emulate(instruction: LR35902.Instruction, followControlFlow: Bool = false) -> LR35902.CPUState {
    let registers8 = LR35902.Instruction.Numeric.registers8
    let registers16 = LR35902.Instruction.Numeric.registers16

    let location = LR35902.Cartridge.location(for: pc, in: bank)!
    let width = LR35902.InstructionSet.widths[instruction.spec]!.total

    var state = self

    switch instruction.spec {
    case .ld(let numeric, .imm8) where registers8.contains(numeric):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      state[numeric] = LR35902.CPUState.RegisterState<UInt8>(value: immediate, sourceLocation: location)
      state.pc += width

    case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
      let srcValue: LR35902.CPUState.RegisterState<UInt8>? = state[src]
      state[dst] = srcValue
      state.pc += width

    case .ld(let dst, .imm16addr) where registers8.contains(dst):
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      state[dst] = LR35902.CPUState.RegisterState<UInt8>(value: nil, sourceLocation: location, variableLocation: immediate)
      state.pc += width

    case .ld(let dst, .imm16) where registers16.contains(dst):
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      state[dst] = LR35902.CPUState.RegisterState<UInt16>(value: immediate, sourceLocation: location)
      state.pc += width

    case .ld(let numeric, .ffimm8addr) where registers8.contains(numeric):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      let address = 0xFF00 | LR35902.Address(immediate)
      let value = ram[address]
      state[numeric] = LR35902.CPUState.RegisterState<UInt8>(value: value?.value, sourceLocation: location, variableLocation: address)
      state.pc += width

    case .ld(.ffimm8addr, let numeric) where registers8.contains(numeric):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      let address = 0xFF00 | LR35902.Address(immediate)
      state.ram[address] = state[numeric]
      state.pc += width

    case .ldi(.hladdr, .a):
      if let dst = state.hl?.value {
        let srcValue: LR35902.CPUState.RegisterState<UInt8>? = state.a
        state.ram[LR35902.Address(dst)] = srcValue
      }
      state.pc += width

    case .ldi(.a, .hladdr):
      if let dst = state.hl?.value {
        state.a = state.ram[LR35902.Address(dst)]
      }
      state.pc += width

    case .xor(.a):
      state.a = .init(value: 0, sourceLocation: location)
      state.pc += width

    case .xor(let numeric) where numeric == .imm8:
      if let dst = state.a?.value,
         case .imm8(let src) = instruction.immediate {
        state.a = .init(value: dst ^ src, sourceLocation: location)
      }
      state.pc += width

    case .xor(let numeric) where registers8.contains(numeric):
      if let dst = state.a?.value,
         let register: LR35902.CPUState.RegisterState<UInt8> = state[numeric],
         let src = register.value {
        state.a = .init(value: dst ^ src, sourceLocation: location)

      } else if let address = state.a?.variableLocation,
                let dst = state.ram[address]?.value,
                let register: LR35902.CPUState.RegisterState<UInt8> = state[numeric],
                let src = register.value {
        state.a = .init(value: dst ^ src, sourceLocation: location)
      }
      state.pc += width

    case .and(let numeric) where registers8.contains(numeric):
      if let dst = state.a?.value,
         let register: LR35902.CPUState.RegisterState<UInt8> = state[numeric],
         let src = register.value {
        state.a = .init(value: dst & src, sourceLocation: location)
        // TODO: Compute the flag bits.
      } else {
        state.a = nil
      }
      state.pc += width

    case .and(.imm8):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      if let dst = state.a?.value {
        state.a = .init(value: dst & immediate, sourceLocation: location)
        // TODO: Compute the flag bits.
      }
      state.pc += width

    case .jp(nil, .imm16):
      if followControlFlow {
        guard case let .imm16(immediate) = instruction.immediate else {
          preconditionFailure("Invalid immediate associated with instruction")
        }
        state.pc = immediate
      } else {
        state.pc += width
      }

    case .call(nil, .imm16):
      if followControlFlow {
        guard case let .imm16(immediate) = instruction.immediate else {
          preconditionFailure("Invalid immediate associated with instruction")
        }
        if var sp = state.sp?.value {
          let pcMSB = UInt8((pc & 0xFF00) >> 8)
          let pcLSB = UInt8(pc & 0x00FF)
          sp -= 1
          state.ram[sp] = .init(value: pcMSB, sourceLocation: location)
          sp -= 1
          state.ram[sp] = .init(value: pcLSB, sourceLocation: location)
          state.sp = .init(value: sp, sourceLocation: location)
        }
        state.pc = immediate
      } else {
        state.pc += width
      }

    case .ld(.sp, .imm16):
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      state.sp = .init(value: immediate, sourceLocation: location)
      state.pc += width

    case .reti, .ret:
      state.a = nil
      state.bc = nil
      state.hl = nil
      state.sp = nil
      state.ram.removeAll()
      state.pc += width

    // TODO: For calls, we need to look up the affected registers and arguments.
    default:
      state.pc += width
    }

    state.next = [location + LR35902.Cartridge.Location(width)]

    return state
  }
}
