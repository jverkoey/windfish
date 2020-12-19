import Foundation

extension LR35902.CPUState {
  public func emulate(instruction: LR35902.Instruction) -> LR35902.CPUState {
    let registers8 = LR35902.Instruction.Numeric.registers8
    let registers16 = LR35902.Instruction.Numeric.registers16

    let location = LR35902.Cartridge.location(for: pc, in: bank)!

    var state = self

    switch instruction.spec {
    case .ld(let numeric, .imm8) where registers8.contains(numeric):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      state[numeric] = LR35902.CPUState.RegisterState<UInt8>(value: .literal(immediate), sourceLocation: location)

    case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
      let srcValue: LR35902.CPUState.RegisterState<UInt8>? = state[src]
      state[dst] = srcValue

    case .ld(let dst, .imm16addr) where registers8.contains(dst):
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      state[dst] = LR35902.CPUState.RegisterState<UInt8>(value: .variable(immediate), sourceLocation: location)

    case .ld(let dst, .imm16) where registers16.contains(dst):
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      state[dst] = LR35902.CPUState.RegisterState<UInt16>(value: .literal(immediate), sourceLocation: location)

    case .ld(let numeric, .ffimm8addr) where registers8.contains(numeric):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      let address = 0xFF00 | LR35902.Address(immediate)
      state[numeric] = LR35902.CPUState.RegisterState<UInt8>(value: .variable(address), sourceLocation: location)

    case .ld(.ffimm8addr, let numeric) where registers8.contains(numeric):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      let address = 0xFF00 | LR35902.Address(immediate)
      state.ram[address] = state[numeric]

    case .ldi(.hladdr, .a):
      if case .literal(let dst) = state.hl?.value {
        let srcValue: LR35902.CPUState.RegisterState<UInt8>? = state.a
        state.ram[LR35902.Address(dst)] = srcValue
      }

    case .ldi(.a, .hladdr):
      if case .literal(let dst) = state.hl?.value {
        state.a = state.ram[LR35902.Address(dst)]
      }

    case .xor(.a):
      state.a = .init(value: .literal(0), sourceLocation: location)

    case .xor(let numeric) where numeric == .imm8:
      if case .literal(let dst) = state.a?.value,
         case .imm8(let src) = instruction.immediate {
        state.a = .init(value: .literal(dst ^ src), sourceLocation: location)
      }

    case .xor(let numeric) where registers8.contains(numeric):
      if case .literal(let dst) = state.a?.value,
         let register: LR35902.CPUState.RegisterState<UInt8> = state[numeric],
         case .literal(let src) = register.value {
        state.a = .init(value: .literal(dst ^ src), sourceLocation: location)

      } else if case .variable(let address) = state.a?.value,
                case .literal(let dst) = state.ram[address]?.value,
                let register: LR35902.CPUState.RegisterState<UInt8> = state[numeric],
                case .literal(let src) = register.value {
        state.a = .init(value: .literal(dst ^ src), sourceLocation: location)
      }

    case .and(let numeric) where registers8.contains(numeric):
      if case .literal(let dst) = state.a?.value,
         let register: LR35902.CPUState.RegisterState<UInt8> = state[numeric],
         case .literal(let src) = register.value {
        state.a = .init(value: .literal(dst & src), sourceLocation: location)
        // TODO: Compute the flag bits.
      } else {
        state.a = nil
      }

    case .and(.imm8):
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      if case .literal(let dst) = state.a?.value {
        state.a = .init(value: .literal(dst & immediate), sourceLocation: location)
        // TODO: Compute the flag bits.
      }

    case .ld(.sp, .imm16):
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      state.sp = .init(value: .literal(immediate), sourceLocation: location)

    case .reti, .ret:
      state.a = nil
      state.bc = nil
      state.hl = nil
      state.sp = nil
      state.ram.removeAll()

    // TODO: For calls, we need to look up the affected registers and arguments.
    default:
      break
    }

    let width = LR35902.InstructionSet.widths[instruction.spec]!.total
    state.next = [location + LR35902.Cartridge.Location(width)]
    state.pc += width

    return state
  }
}
