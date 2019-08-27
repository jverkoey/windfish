import Foundation

extension LR35902.Disassembly {
  struct CPUState {
    enum RegisterValue<T: BinaryInteger>: Equatable {
      case variable(LR35902.Address)
      case value(T)
    }
    struct RegisterState<T: BinaryInteger>: Equatable {
      let value: RegisterValue<T>
      let sourceLocation: LR35902.CartridgeLocation
    }
    var a: RegisterState<UInt8>?
    var b: RegisterState<UInt8>?
    var c: RegisterState<UInt8>?
    var d: RegisterState<UInt8>?
    var e: RegisterState<UInt8>?
    var h: RegisterState<UInt8>?
    var l: RegisterState<UInt8>?
    var bc: RegisterState<UInt16>? {
      get {
        if let sourceLocation = b?.sourceLocation,
          case .value(let b) = b?.value,
          case .value(let c) = c?.value {
          return RegisterState<UInt16>(value: .value(UInt16(b) << 8 | UInt16(c)), sourceLocation: sourceLocation)
        }
        return _bc
      }
      set {
        if let sourceLocation = newValue?.sourceLocation,
          case .value(let bc) = newValue?.value {
          b = .init(value: .value(UInt8(bc >> 8)), sourceLocation: sourceLocation)
          c = .init(value: .value(UInt8(bc & 0x00FF)), sourceLocation: sourceLocation)
        }
        _bc = newValue
      }
    }
    private var _bc: RegisterState<UInt16>?
    var hl: RegisterState<UInt16>? {
      get {
        if let sourceLocation = h?.sourceLocation,
          case .value(let h) = h?.value,
          case .value(let l) = l?.value {
          return RegisterState<UInt16>(value: .value(UInt16(h) << 8 | UInt16(l)), sourceLocation: sourceLocation)
        }
        return _hl
      }
      set {
        if let sourceLocation = newValue?.sourceLocation,
          case .value(let hl) = newValue?.value {
          h = .init(value: .value(UInt8(hl >> 8)), sourceLocation: sourceLocation)
          l = .init(value: .value(UInt8(hl & 0x00FF)), sourceLocation: sourceLocation)
        }
        _hl = newValue
      }
    }
    private var _hl: RegisterState<UInt16>?
    var sp: RegisterState<UInt16>?
    var next: [LR35902.CartridgeLocation] = []
    var ram: [LR35902.Address: RegisterState<UInt8>] = [:]

    subscript(numeric: LR35902.Instruction.Numeric) -> RegisterState<UInt8>? {
      get {
        switch numeric {
        case .a: return a
        case .b: return b
        case .c: return c
        case .d: return d
        case .e: return e
        default: return nil
        }
      }
      set {
        switch numeric {
        case .a: a = newValue
        case .b: b = newValue
        case .c: c = newValue
        case .d: d = newValue
        case .e: e = newValue
        default: break
        }
      }
    }

    subscript(numeric: LR35902.Instruction.Numeric) -> RegisterState<UInt16>? {
      get {
        switch numeric {
        case .bc: return bc
        case .hl: return hl
        default: return nil
        }
      }
      set {
        switch numeric {
        case .bc: bc = newValue
        case .hl: hl = newValue
        default: break
        }
      }
    }
  }

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
  func simulate(range: Range<LR35902.CartridgeLocation>,
                initialState: CPUState = CPUState(),
                step: ((LR35902.Instruction, LR35902.CartridgeLocation, CPUState) -> Void)? = nil)
    -> [LR35902.CartridgeLocation: CPUState] {
      var (pc, bank) = LR35902.addressAndBank(from: range.lowerBound)
      let upperBoundPc = LR35902.addressAndBank(from: range.upperBound).address

      var state = initialState

      // TODO: Store this globally.
      var states: [LR35902.CartridgeLocation: CPUState] = [:]

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

        let location = LR35902.cartAddress(for: pc, in: bank)!

        switch instruction.spec {
        case .ld(let numeric, .imm8) where registers8.contains(numeric):
          state[numeric] = CPUState.RegisterState<UInt8>(value: .value(instruction.imm8!), sourceLocation: location)

        case .ld(let dst, let src) where registers8.contains(dst) && registers8.contains(src):
          let srcValue: CPUState.RegisterState<UInt8>? = state[src]
          state[dst] = srcValue

        case .ld(let dst, .imm16addr) where registers8.contains(dst):
          state[dst] = CPUState.RegisterState<UInt8>(value: .variable(instruction.imm16!), sourceLocation: location)

        case .ld(let dst, .imm16) where registers16.contains(dst):
          state[dst] = CPUState.RegisterState<UInt16>(value: .value(instruction.imm16!), sourceLocation: location)

        case .ld(let numeric, .ffimm8addr) where registers8.contains(numeric):
          let address = 0xFF00 | LR35902.Address(instruction.imm8!)
          state[numeric] = CPUState.RegisterState<UInt8>(value: .variable(address), sourceLocation: location)

        case .ld(.ffimm8addr, let numeric) where registers8.contains(numeric):
          let address = 0xFF00 | LR35902.Address(instruction.imm8!)
          state.ram[address] = state[numeric]

        case .xor(.a):
          state.a = .init(value: .value(0), sourceLocation: location)

        case .xor(let numeric) where registers8.contains(numeric):
          if case .value(let dst) = state.a?.value,
            let register: CPUState.RegisterState<UInt8> = state[numeric],
            case .value(let src) = register.value {
            state.a = .init(value: .value(dst ^ src), sourceLocation: location)

          } else if case .variable(let address) = state.a?.value,
            case .value(let dst) = state.ram[address]?.value,
            let register: CPUState.RegisterState<UInt8> = state[numeric],
            case .value(let src) = register.value {
            state.a = .init(value: .value(dst ^ src), sourceLocation: location)
          }

        case .and(let numeric) where registers8.contains(numeric):
          if case .value(let dst) = state.a?.value,
            let register: CPUState.RegisterState<UInt8> = state[numeric],
            case .value(let src) = register.value {
            state.a = .init(value: .value(dst & src), sourceLocation: location)
            // TODO: Compute the flag bits.
          } else {
            state.a = nil
          }

        case .and(.imm8):
          if case .value(let dst) = state.a?.value {
            state.a = .init(value: .value(dst & instruction.imm8!), sourceLocation: location)
            // TODO: Compute the flag bits.
          }

        case .ld(.sp, .imm16):
          state.sp = .init(value: .value(instruction.imm16!), sourceLocation: location)

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

        let width = LR35902.Instruction.widths[instruction.spec]!.total

        var thisState = state
        thisState.next = [location + LR35902.CartridgeLocation(width)]
        states[location] = thisState

        pc += width
      }

      return states
  }
}
