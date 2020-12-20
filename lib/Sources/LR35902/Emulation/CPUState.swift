import Foundation

extension LR35902 {
  /**
   A representation of the LR35902 state at a specific moment.

   All registers are optional, allowing for the representation of registers being in an unknown state in order to
   support emulation of a block of instructions that might be reached from unknown locations or a variety of states.
   */
  public struct CPUState {
    // MARK: 8-bit registers
    public var a: UInt8 = 0
    public var b: UInt8 = 0
    public var c: UInt8 = 0
    public var d: UInt8 = 0
    public var e: UInt8 = 0
    public var h: UInt8 = 0
    public var l: UInt8 = 0

    /** Flag register bits. */
    public var fzero: Bool = false
    public var fsubtract: Bool = false
    public var fhalfcarry: Bool = false
    public var fcarry: Bool = false

    /** Flag register. */
    public var f: UInt8 {
      get {
        return
          (fzero        ? 0b1000_0000 : 0)
          | (fsubtract  ? 0b0100_0000 : 0)
          | (fhalfcarry ? 0b0010_0000 : 0)
          | (fcarry     ? 0b0001_0000 : 0)
      }
      set {
        fzero       = newValue & 0b1000_0000 != 0
        fsubtract   = newValue & 0b0100_0000 != 0
        fhalfcarry  = newValue & 0b0010_0000 != 0
        fcarry      = newValue & 0b0001_0000 != 0
      }
    }

    // MARK: 16-bit registers
    // Note that, though these registers are ultimately backed by the underlying 8 bit registers, each 16-bit register
    // also stores the state value that was directly assigned to it.
    public var bc: UInt16 {
      get { return UInt16(b) << 8 | UInt16(c) }
      set {
        b = UInt8(newValue >> 8)
        c = UInt8(newValue & 0x00FF)
      }
    }
    public var de: UInt16 {
      get { return UInt16(d) << 8 | UInt16(e) }
      set {
        d = UInt8(newValue >> 8)
        e = UInt8(newValue & 0x00FF)
      }
    }
    public var hl: UInt16 {
      get { return UInt16(h) << 8 | UInt16(l) }
      set {
        h = UInt8(newValue >> 8)
        l = UInt8(newValue & 0x00FF)
      }
    }

    /** Stack pointer. */
    public var sp: UInt16 = 0

    /** Random access memory. */
    public var ram: [LR35902.Address: UInt8] = [:]

    /** Program counter. */
    public var pc: Address = 0

    /** Selected bank. */
    public var bank: Bank = 0

    /** Trace information for a given register. */
    public var registerTraces: [LR35902.Instruction.Numeric: RegisterTrace] = [:]

    /** Initializes the state with initial immediate values. */
    public init(a: UInt8 = 0, b: UInt8 = 0, c: UInt8 = 0, d: UInt8 = 0, e: UInt8 = 0, h: UInt8 = 0, l: UInt8 = 0, fzero: Bool = false, fsubtract: Bool = false, fhalfcarry: Bool = false, fcarry: Bool = false, sp: UInt16 = 0, ram: [LR35902.Address : UInt8] = [:], pc: LR35902.Address = 0, bank: LR35902.Bank = 0, registerTraces: [LR35902.Instruction.Numeric : LR35902.CPUState.RegisterTrace] = [:]) {
      self.a = a
      self.b = b
      self.c = c
      self.d = d
      self.e = e
      self.h = h
      self.l = l
      self.fzero = fzero
      self.fsubtract = fsubtract
      self.fhalfcarry = fhalfcarry
      self.fcarry = fcarry
      self.sp = sp
      self.ram = ram
      self.pc = pc
      self.bank = bank
      self.registerTraces = registerTraces
    }
  }
}

// MARK: - Subscript access

extension LR35902.CPUState {
  // MARK: Subscript access of instructions using LR35902 instruction specifications
  /** 8-bit register subscript. */
  public subscript(numeric: LR35902.Instruction.Numeric) -> UInt8 {
    get {
      switch numeric {
      case .a: return a
      case .b: return b
      case .c: return c
      case .d: return d
      case .e: return e
      case .h: return h
      case .l: return l
      default:
        preconditionFailure()
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
      default:
        preconditionFailure()
      }
    }
  }
  /** 16-bit register subscript. */
  public subscript(numeric: LR35902.Instruction.Numeric) -> UInt16 {
    get {
      switch numeric {
      case .bc: return bc
      case .de: return de
      case .hl: return hl
      case .sp: return sp
      default:
        preconditionFailure()
      }
    }
    set {
      switch numeric {
      case .bc: bc = newValue
      case .de: de = newValue
      case .hl: hl = newValue
      case .sp: sp = newValue
      default:
        preconditionFailure()
      }
    }
  }

  /** Resets the register state. */
  public mutating func clear(_ numeric: LR35902.Instruction.Numeric) {
    switch numeric {
    case .a: a = 0
    case .b: b = 0
    case .c: c = 0
    case .d: d = 0
    case .e: e = 0
    case .h: h = 0
    case .l: l = 0
    case .bc: bc = 0
    case .de: de = 0
    case .hl: hl = 0
    case .sp: sp = 0
    default:
      preconditionFailure()
    }
    registerTraces.removeValue(forKey: numeric)
  }
}

extension LR35902.CPUState {
  /** Trace information for a specific register. */
  public struct RegisterTrace: Equatable {
    public init(sourceLocation: LR35902.Cartridge.Location) {
      self.sourceLocation = sourceLocation
      self.loadAddress = nil
    }
    public init(loadAddress: LR35902.Address) {
      self.sourceLocation = nil
      self.loadAddress = loadAddress
    }
    public init(sourceLocation: LR35902.Cartridge.Location, loadAddress: LR35902.Address) {
      self.sourceLocation = sourceLocation
      self.loadAddress = loadAddress
    }

    /** The address from which the value was loaded, if known. */
    public let loadAddress: LR35902.Address?

    /** The cartridge location at which this register's value was loaded, if known. */
    public let sourceLocation: LR35902.Cartridge.Location?
  }
}
