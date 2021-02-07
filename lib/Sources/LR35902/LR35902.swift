import Foundation

// References:
// - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
// - https://gekkio.fi/files/gb-docs/gbctr.pdf
// - https://www.reddit.com/r/EmuDev/comments/7qf352/game_boy_is_0xcb_a_separate_instruction_are/
//   - "Important: an interrupt CANNOT happen between 0xCB and the other operand."
// - https://mgba.io/2017/04/30/emulation-accuracy/
// - https://www.reddit.com/r/emulation/comments/53jdqj/what_exactly_is_a_cycleaccurate_emulator/

/**
 A sparse representation of the LR35902 CPU.

 Each register is optional and nil by default. This allows the disassembler to trace instructions with confidence that
 any non-nil value represents a known value, while nil values represent unknown state.
 */
public final class LR35902 {
  public typealias Address = UInt16

  // MARK: 8-bit registers
  public var a: UInt8?
  public var b: UInt8?
  public var c: UInt8?
  public var d: UInt8?
  public var e: UInt8?
  public var h: UInt8?
  public var l: UInt8?

  /**
   The zero flag (Z).

   This flag is set when the result of a math operation is zero or two values match when using the CP instruction.
   */
  public var fzero: Bool?

  /**
   The subtract flag (N).

   This flag is set if a subtraction was performed in the last math instruction.
   */
  public var fsubtract: Bool?

  /**
   The half-carry flag flag (H).

   This flag is set if a carry occurred from the lower nibble in the last math operation.
   */
  public var fhalfcarry: Bool?

  /**
   The carry flag (C).

   This flag is set if a carry occurred from the last math operation or if register A is the smaller value when
   executing the CP instruction.
   */
  public var fcarry: Bool?

  /** Flag register. */
  public var f: UInt8? {
    get {
      guard let fzero = fzero,
            let fsubtract = fsubtract,
            let fhalfcarry = fhalfcarry,
            let fcarry = fcarry else {
        return nil
      }
      return
        (fzero        ? 0b1000_0000 : 0)
        | (fsubtract  ? 0b0100_0000 : 0)
        | (fhalfcarry ? 0b0010_0000 : 0)
        | (fcarry     ? 0b0001_0000 : 0)
    }
    set {
      guard let newValue = newValue else {
        fzero = nil
        fsubtract = nil
        fhalfcarry = nil
        fcarry = nil
        return
      }
      fzero       = newValue & 0b1000_0000 != 0
      fsubtract   = newValue & 0b0100_0000 != 0
      fhalfcarry  = newValue & 0b0010_0000 != 0
      fcarry      = newValue & 0b0001_0000 != 0
    }
  }

  /**
   The halt status.

   When true, the CPU will stop executing instructions until the next interrupt occurs.
   */
  public var halted: Bool?

  // MARK: 16-bit registers

  public var af: UInt16? {
    get {
      guard let a = a, let f = f else {
        return nil
      }
      return UInt16(a) << 8 | UInt16(f)
    }
    set {
      guard let newValue = newValue else {
        a = nil
        f = nil
        return
      }
      a = UInt8(newValue >> 8)
      f = UInt8(newValue & 0x00FF)
    }
  }
  public var bc: UInt16? {
    get {
      guard let b = b, let c = c else {
        return nil
      }
      return UInt16(b) << 8 | UInt16(c)
    }
    set {
      guard let newValue = newValue else {
        b = nil
        c = nil
        return
      }
      b = UInt8(newValue >> 8)
      c = UInt8(newValue & 0x00FF)
    }
  }
  public var de: UInt16? {
    get {
      guard let d = d, let e = e else {
        return nil
      }
      return UInt16(d) << 8 | UInt16(e)
    }
    set {
      guard let newValue = newValue else {
        d = nil
        e = nil
        return
      }
      d = UInt8(newValue >> 8)
      e = UInt8(newValue & 0x00FF)
    }
  }
  public var hl: UInt16? {
    get {
      guard let h = h, let l = l else {
        return nil
      }
      return UInt16(h) << 8 | UInt16(l)
    }
    set {
      guard let newValue = newValue else {
        h = nil
        l = nil
        return
      }
      h = UInt8(newValue >> 8)
      l = UInt8(newValue & 0x00FF)
    }
  }

  /** Stack pointer. */
  public var sp: UInt16?

  /** Program counter. */
  public var pc: Address = 0x0000

  /** Initializes the CPU with all nil values. */
  public init() {}

  internal init(a: UInt8? = nil, b: UInt8? = nil, c: UInt8? = nil, d: UInt8? = nil, e: UInt8? = nil, h: UInt8? = nil, l: UInt8? = nil, fzero: Bool? = nil, fsubtract: Bool? = nil, fhalfcarry: Bool? = nil, fcarry: Bool? = nil, halted: Bool? = nil, sp: UInt16? = nil, pc: LR35902.Address = 0x0000) {
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
    self.halted = halted
    self.sp = sp
    self.pc = pc
  }

  public static func zeroed() -> LR35902 {
    return LR35902(a: 0, b: 0, c: 0, d: 0, e: 0, h: 0, l: 0, fzero: false, fsubtract: false, fhalfcarry: false, fcarry: false, sp: 0, pc: 0)
  }

  public func copy() -> LR35902 {
    return LR35902(a: a, b: b, c: c, d: d, e: e, h: h, l: l, fzero: fzero, fsubtract: fsubtract, fhalfcarry: fhalfcarry, fcarry: fcarry, halted: halted, sp: sp, pc: pc)
  }
}

// MARK: - Subscript access

extension LR35902 {
  // MARK: Subscript access of instructions using LR35902 instruction specifications
  /** 8-bit register subscript. */
  public subscript(numeric: LR35902.Instruction.Numeric) -> UInt8? {
    get { return get(numeric8: numeric) }
    set { set(numeric8: numeric, to: newValue) }
  }
  /** 16-bit register subscript. */
  public subscript(numeric: LR35902.Instruction.Numeric) -> UInt16? {
    get { return get(numeric16: numeric) }
    set { set(numeric16: numeric, to: newValue) }
  }

  public func get(numeric8: LR35902.Instruction.Numeric) -> UInt8? {
    switch numeric8 {
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
  public func set(numeric8: LR35902.Instruction.Numeric, to newValue: UInt8?) {
    switch numeric8 {
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

  public func get(numeric16: LR35902.Instruction.Numeric) -> UInt16? {
    switch numeric16 {
    case .af:           return af
    case .bc, .bcaddr:  return bc
    case .de, .deaddr:  return de
    case .hl, .hladdr:  return hl
    case .sp:           return sp
    default:
      preconditionFailure()
    }
  }
  public func set(numeric16: LR35902.Instruction.Numeric, to newValue: UInt16?) {
    switch numeric16 {
    case .af:           af = newValue
    case .bc, .bcaddr:  bc = newValue
    case .de, .deaddr:  de = newValue
    case .hl, .hladdr:  hl = newValue
    case .sp:           sp = newValue
    default:
      preconditionFailure()
    }
  }
}
