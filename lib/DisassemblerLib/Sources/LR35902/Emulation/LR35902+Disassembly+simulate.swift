import Foundation

extension LR35902.Disassembly {
  // TODO: Extract this engine into a generic emulator so that the following code can be debugged in an interactive session:
  /*
   ; Store the read joypad state into c
   ld   c, a                                    ; $282A (00): ReadJoypadState $4F
   ld   a, [hPreviousJoypadState]               ; $282B (00): ReadJoypadState $F0 $CB
   xor  c                                       ; $282D (00): ReadJoypadState $A9
   and  c                                       ; $282E (00): ReadJoypadState $A1
   ld   [hJoypadState], a                       ; $282F (00): ReadJoypadState $E0 $CC
   ld   a, c                                    ; $2831 (00): ReadJoypadState $79
   ld   [hPreviousJoypadState], a               ; $2832 (00): ReadJoypadState $E0 $CB
   */
  @discardableResult
  func simulate(range: Range<LR35902.Cartridge.Location>,
                initialState: LR35902.CPUState = LR35902.CPUState(),
                step: ((LR35902.Instruction, LR35902.Cartridge.Location, LR35902.CPUState) -> Void)? = nil)
    -> [LR35902.Cartridge.Location: LR35902.CPUState] {
      var (pc, bank) = LR35902.Cartridge.addressAndBank(from: range.lowerBound)
      let upperBoundPc = LR35902.Cartridge.addressAndBank(from: range.upperBound).address

      var state = initialState

      // TODO: Store this globally.
      var states: [LR35902.Cartridge.Location: LR35902.CPUState] = [:]

      let registers8 = LR35902.Instruction.Numeric.registers8
      let registers16: Set<LR35902.Instruction.Numeric> = Set([
        .bc,
        .hl,
      ])

      while pc < upperBoundPc {
        guard let instruction = self.instruction(at: pc, in: bank) else {
          pc += 1
          continue
        }

        let location = LR35902.Cartridge.location(for: pc, in: bank)!

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

        step?(instruction, location, state)

        let width = LR35902.InstructionSet.widths[instruction.spec]!.total

        var thisState = state
        thisState.next = [location + LR35902.Cartridge.Location(width)]
        states[location] = thisState

        pc += width
      }

      return states
  }
}
