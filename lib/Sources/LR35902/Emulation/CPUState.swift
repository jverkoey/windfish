import Foundation

extension LR35902 {
  /**
   A representation of the LR35902 state at a specific moment.

   All registers are optional, allowing for the representation of registers being in an unknown state in order to
   support emulation of a block of instructions that might be reached from unknown locations or a variety of states.
   */
  struct CPUState {

    // MARK: 8-bit registers
    var a: RegisterState<UInt8>?
    var b: RegisterState<UInt8>?
    var c: RegisterState<UInt8>?
    var d: RegisterState<UInt8>?
    var e: RegisterState<UInt8>?
    var h: RegisterState<UInt8>?
    var l: RegisterState<UInt8>?

    // MARK: 16-bit registers
    // Note that, though these registers are ultimately backed by the underlying 8 bit registers, each 16-bit register
    // also stores the state value that was directly assigned to it.
    var bc: RegisterState<UInt16>? {
      get { return get(high: b, low: c) ?? _bc }
      set { set(register: &_bc, newValue: newValue, high: &b, low: &c) }
    }
    var de: RegisterState<UInt16>? {
      get { return get(high: d, low: e) ?? _de }
      set { set(register: &_de, newValue: newValue, high: &d, low: &e) }
    }
    var hl: RegisterState<UInt16>? {
      get { return get(high: h, low: l) ?? _hl }
      set { set(register: &_hl, newValue: newValue, high: &h, low: &l) }
    }

    /** Stack pointer. */
    var sp: RegisterState<UInt16>?

    /** Random access memory. */
    var ram: [LR35902.Address: RegisterState<UInt8>] = [:]

    // One or more addresses that this state can move to upon execution.
    var next: [LR35902.Cartridge.Location] = []

    /** Program counter. */
    var pc: Address = 0

    /** Selected bank. */
    var bank: Bank = 0

    // MARK: Subscript access of instructions using LR35902 instruction specifications
    /** 8-bit register subscript. */
    subscript(numeric: LR35902.Instruction.Numeric) -> RegisterState<UInt8>? {
      get {
        switch numeric {
        case .a: return a
        case .b: return b
        case .c: return c
        case .d: return d
        case .e: return e
        case .h: return h
        case .l: return l
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
        case .h: h = newValue
        case .l: l = newValue
        default: break
        }
      }
    }
    /** 16-bit register subscript. */
    subscript(numeric: LR35902.Instruction.Numeric) -> RegisterState<UInt16>? {
      get {
        switch numeric {
        case .bc: return bc
        case .de: return de
        case .hl: return hl
        default: return nil
        }
      }
      set {
        switch numeric {
        case .bc: bc = newValue
        case .de: de = newValue
        case .hl: hl = newValue
        default: break
        }
      }
    }

    /** The state of an specific register. */
    struct RegisterState<T: BinaryInteger>: Equatable {
      enum Value: Equatable {
        /** The register's value is defined by the value of some bytes in ram (which may not be known). */
        case variable(LR35902.Address)

        /** The register's value is defined by a literal (and is known). */
        case literal(T)
      }
      let value: Value

      /** The cartridge location from which this register's value was loaded. */
      let sourceLocation: LR35902.Cartridge.Location
    }

    private var _bc: RegisterState<UInt16>?
    private var _de: RegisterState<UInt16>?
    private var _hl: RegisterState<UInt16>?
  }
}

extension LR35902.CPUState {
  private func get(high: RegisterState<UInt8>?, low: RegisterState<UInt8>?) -> RegisterState<UInt16>? {
    // TODO: Find a better way to store sourceLocation that's bound across both registers as this is likely to break in some cases.
    if let sourceLocation = high?.sourceLocation,
       case .literal(let high) = high?.value,
       case .literal(let low) = low?.value {
      return RegisterState<UInt16>(value: .literal(UInt16(high) << 8 | UInt16(low)), sourceLocation: sourceLocation)
    }
    return nil
  }

  private func set(register: inout RegisterState<UInt16>?, newValue: RegisterState<UInt16>?,
                   high: inout RegisterState<UInt8>?, low: inout RegisterState<UInt8>?) {
    if let sourceLocation = newValue?.sourceLocation,
       case .literal(let value) = newValue?.value {
      high = .init(value: .literal(UInt8(value >> 8)), sourceLocation: sourceLocation)
      low = .init(value: .literal(UInt8(value & 0x00FF)), sourceLocation: sourceLocation)
    }
    register = newValue
  }
}

extension LR35902.CPUState {
  /** Initializes the state with initial immediate values. */
  init(a: UInt8? = nil, b: UInt8? = nil,
       c: UInt8? = nil, d: UInt8? = nil,
       e: UInt8? = nil,
       h: UInt8? = nil, l: UInt8? = nil) {
    if let a = a {
      self.a = .init(value: .literal(a), sourceLocation: 0)
    }
    if let b = b {
      self.b = .init(value: .literal(b), sourceLocation: 0)
    }
    if let c = c {
      self.c = .init(value: .literal(c), sourceLocation: 0)
    }
    if let d = d {
      self.d = .init(value: .literal(d), sourceLocation: 0)
    }
    if let e = e {
      self.e = .init(value: .literal(e), sourceLocation: 0)
    }
    if let h = h {
      self.h = .init(value: .literal(h), sourceLocation: 0)
    }
    if let l = l {
      self.l = .init(value: .literal(l), sourceLocation: 0)
    }
  }
}
