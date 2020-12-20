import Foundation

extension LR35902 {
  /**
   A representation of the LR35902 state at a specific moment.

   All registers are optional, allowing for the representation of registers being in an unknown state in order to
   support emulation of a block of instructions that might be reached from unknown locations or a variety of states.
   */
  public struct CPUState {

    // MARK: 8-bit registers
    public var a: RegisterState<UInt8>?
    public var b: RegisterState<UInt8>?
    public var c: RegisterState<UInt8>?
    public var d: RegisterState<UInt8>?
    public var e: RegisterState<UInt8>?
    public var h: RegisterState<UInt8>?
    public var l: RegisterState<UInt8>?

    // MARK: 16-bit registers
    // Note that, though these registers are ultimately backed by the underlying 8 bit registers, each 16-bit register
    // also stores the state value that was directly assigned to it.
    public var bc: RegisterState<UInt16>? {
      get { return get(high: b, low: c) ?? _bc }
      set { set(register: &_bc, newValue: newValue, high: &b, low: &c) }
    }
    public var de: RegisterState<UInt16>? {
      get { return get(high: d, low: e) ?? _de }
      set { set(register: &_de, newValue: newValue, high: &d, low: &e) }
    }
    public var hl: RegisterState<UInt16>? {
      get { return get(high: h, low: l) ?? _hl }
      set { set(register: &_hl, newValue: newValue, high: &h, low: &l) }
    }

    /** Stack pointer. */
    public var sp: RegisterState<UInt16>?

    /** Random access memory. */
    public var ram: [LR35902.Address: RegisterState<UInt8>] = [:]

    // One or more addresses that this state can move to upon execution.
    public var next: [LR35902.Cartridge.Location] = []

    /** Program counter. */
    public var pc: Address

    /** Selected bank. */
    public var bank: Bank

    // MARK: Subscript access of instructions using LR35902 instruction specifications
    /** 8-bit register subscript. */
    public subscript(numeric: LR35902.Instruction.Numeric) -> RegisterState<UInt8>? {
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
    public subscript(numeric: LR35902.Instruction.Numeric) -> RegisterState<UInt16>? {
      get {
        switch numeric {
        case .bc: return bc
        case .de: return de
        case .hl: return hl
        case .sp: return sp
        default: return nil
        }
      }
      set {
        switch numeric {
        case .bc: bc = newValue
        case .de: de = newValue
        case .hl: hl = newValue
        case .sp: sp = newValue
        default: break
        }
      }
    }

    /** Resets the register state to nil. */
    public mutating func clear(_ numeric: LR35902.Instruction.Numeric) {
      switch numeric {
      case .a: a = nil
      case .b: b = nil
      case .c: c = nil
      case .d: d = nil
      case .e: e = nil
      case .h: h = nil
      case .l: l = nil
      case .bc: bc = nil
      case .de: de = nil
      case .hl: hl = nil
      case .sp: sp = nil
      default:
        preconditionFailure()
      }
    }

    /** The state of an specific register. */
    public struct RegisterState<T: BinaryInteger>: Equatable {
      public init(value: T?, sourceLocation: LR35902.Cartridge.Location? = nil, variableLocation: LR35902.Address? = nil) {
        self.value = value
        self.sourceLocation = sourceLocation
        self.variableLocation = variableLocation
      }

      /** The register's value represented as a literal, if known. */
      public var value: T?

      /** The address from which the value was loaded. */
      public let variableLocation: LR35902.Address?

      /** The cartridge location from which this register's value was loaded, if known. */
      public let sourceLocation: LR35902.Cartridge.Location?
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
       let high = high?.value,
       let low = low?.value {
      return RegisterState<UInt16>(value: UInt16(high) << 8 | UInt16(low), sourceLocation: sourceLocation)
    }
    return nil
  }

  private func set(register: inout RegisterState<UInt16>?, newValue: RegisterState<UInt16>?,
                   high: inout RegisterState<UInt8>?, low: inout RegisterState<UInt8>?) {
    if let sourceLocation = newValue?.sourceLocation,
       let value = newValue?.value {
      high = .init(value: UInt8(value >> 8), sourceLocation: sourceLocation)
      low = .init(value: UInt8(value & 0x00FF), sourceLocation: sourceLocation)
    }
    register = newValue
  }
}

extension LR35902.CPUState {
  /** Initializes the state with initial immediate values. */
  public init(a: UInt8? = nil, b: UInt8? = nil,
       c: UInt8? = nil, d: UInt8? = nil,
       e: UInt8? = nil,
       h: UInt8? = nil, l: UInt8? = nil,
       sp: UInt16? = nil,
       pc: LR35902.Address = 0, bank: LR35902.Bank = 0) {
    if let a = a {
      self.a = .init(value: a)
    }
    if let b = b {
      self.b = .init(value: b)
    }
    if let c = c {
      self.c = .init(value: c)
    }
    if let d = d {
      self.d = .init(value: d)
    }
    if let e = e {
      self.e = .init(value: e)
    }
    if let h = h {
      self.h = .init(value: h)
    }
    if let l = l {
      self.l = .init(value: l)
    }
    if let sp = sp {
      self.sp = .init(value: sp)
    }
    self.pc = pc
    self.bank = bank
  }
}
