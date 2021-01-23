import Foundation

// References:
// - https://realboyemulator.files.wordpress.com/2013/01/gbcpuman.pdf
// - https://gekkio.fi/files/gb-docs/gbctr.pdf
// - https://www.reddit.com/r/EmuDev/comments/7qf352/game_boy_is_0xcb_a_separate_instruction_are/
//   - "Important: an interrupt CANNOT happen between 0xCB and the other operand."
// - https://mgba.io/2017/04/30/emulation-accuracy/
// - https://www.reddit.com/r/emulation/comments/53jdqj/what_exactly_is_a_cycleaccurate_emulator/

/** A representation of the LR35902 CPU. */
public final class LR35902 {
  public typealias Address = UInt16

  // MARK: 8-bit registers
  public var a: UInt8 = 0x01
  public var b: UInt8 = 0x00
  public var c: UInt8 = 0x13
  public var d: UInt8 = 0x00
  public var e: UInt8 = 0xD8
  public var h: UInt8 = 0x01
  public var l: UInt8 = 0x4D

  /**
   The zero flag (Z).

   This flag is set when the result of a math operation is zero or two values match when using the CP instruction.
   */
  public var fzero: Bool = true

  /**
   The subtract flag (N).

   This flag is set if a subtraction was performed in the last math instruction.
   */
  public var fsubtract: Bool = false

  /**
   The half-carry flag flag (H).

   This flag is set if a carry occurred from the lower nibble in the last math operation.
   */
  public var fhalfcarry: Bool = true

  /**
   The carry flag (C).

   This flag is set if a carry occurred from the last math operation or if register A is the smaller value when
   executing the CP instruction.
   */
  public var fcarry: Bool = true

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

  /**
   The interrupt master enable flag (IME).

   When false, all interrupts are disabled.
   When true, interrupts are enabled conditionally on the IE register.
   */
  public var ime: Bool = false

  /** Enabled bits represent a requested interrupt. */
  var interruptEnable: Interrupt = []

  /** Enabled bits represent a requested interrupt. */
  public var interruptFlag: Interrupt = []

  /** A representation of a Gameboy interrupt. */
  public struct Interrupt: OptionSet, Hashable {
    public init(rawValue: UInt8) {
      self.rawValue = rawValue
    }

    public let rawValue: UInt8

    public static let joypad       = Interrupt(rawValue: 0b0001_0000)
    public static let serial       = Interrupt(rawValue: 0b0000_1000)
    public static let timer        = Interrupt(rawValue: 0b0000_0100)
    public static let lcdStat      = Interrupt(rawValue: 0b0000_0010)
    public static let vBlank       = Interrupt(rawValue: 0b0000_0001)
  }

  /**
   The halt status.

   When true, the CPU will stop executing instructions until the next interrupt occurs.
   */
  public var halted: Bool = false

  /** Indicates whether the CPU is fetching and executing instructions. */
  public var isRunning: Bool {
    return !halted
  }

  /** If positive, will be decremented on each machine cycle and ime will be enabled once zero. */
  var imeToggleDelay = 0

  // MARK: 16-bit registers
  // Note that, though these registers are ultimately backed by the underlying 8 bit registers, each 16-bit register
  // also stores the state value that was directly assigned to it.
  public var af: UInt16 {
    get { return UInt16(a) << 8 | UInt16(f) }
    set {
      a = UInt8(newValue >> 8)
      f = UInt8(newValue & 0x00FF)
    }
  }
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
  public var sp: UInt16 = 0xFFFE

  /** Program counter. */
  public var pc: Address = 0x0000

  /** The machine instruction represents the CPU's understanding of its current instruction. */
  public var machineInstruction = MachineInstruction()

  /** Trace information for a given register. */
  // TODO: Allow the CPU to be wrapped in a tracing emulator that intercepts certain types of instructions to log tracer information.
  var registerTraces: [LR35902.Instruction.Numeric: RegisterTrace] = [:]

  var nextAction: LR35902.Emulation.EmulationResult = .fetchNext
  var specIndex: Int = 0

  public final class MachineInstruction {
    init() {}

    public internal(set) var spec: Instruction.Spec?
    var instructionEmulator: InstructionEmulator? {
      didSet {
        cycle = 0
      }
    }
    public internal(set) var sourceLocation: Gameboy.SourceLocation?
    var cycle: Int = 0

    public func sourceAddress() -> LR35902.Address? {
      switch sourceLocation {
      case .cartridge(let location):  return location.address
      case .memory(let address):      return address
      default:
        return nil
      }
    }
    public func sourceAddressAndBank() -> (address: LR35902.Address, bank: Cartridge.Bank)? {
      guard case let .cartridge(location) = sourceLocation else {
        return nil
      }
      return (address: location.address, bank: location.bank)
    }
  }

  /** Initializes the state with boot values. */
  public init() {}

  internal init(a: UInt8 = 0, b: UInt8 = 0, c: UInt8 = 0, d: UInt8 = 0, e: UInt8 = 0, h: UInt8 = 0, l: UInt8 = 0, fzero: Bool = false, fsubtract: Bool = false, fhalfcarry: Bool = false, fcarry: Bool = false, ime: Bool = false, interruptEnable: LR35902.Interrupt = [], interruptFlag: LR35902.Interrupt = [], halted: Bool = false, imeToggleDelay: Int = 0, sp: UInt16 = 0, pc: LR35902.Address = 0, machineInstruction: LR35902.MachineInstruction = MachineInstruction(), registerTraces: [LR35902.Instruction.Numeric : LR35902.RegisterTrace] = [:], nextAction: LR35902.Emulation.EmulationResult = .fetchNext) {
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
    self.ime = ime
    self.interruptEnable = interruptEnable
    self.interruptFlag = interruptFlag
    self.halted = halted
    self.imeToggleDelay = imeToggleDelay
    self.sp = sp
    self.pc = pc
    self.machineInstruction = machineInstruction
    self.registerTraces = registerTraces
    self.nextAction = nextAction
  }

  public static func zeroed() -> LR35902 {
    return LR35902(a: 0, b: 0, c: 0, d: 0, e: 0, h: 0, l: 0, fzero: false, fsubtract: false, fhalfcarry: false, fcarry: false, sp: 0, pc: 0, registerTraces: [:])
  }

  public func copy() -> LR35902 {
    return LR35902(a: a, b: b, c: c, d: d, e: e, h: h, l: l, fzero: fzero, fsubtract: fsubtract, fhalfcarry: fhalfcarry, fcarry: fcarry, ime: ime, interruptEnable: interruptEnable, interruptFlag: interruptFlag, halted: halted, imeToggleDelay: imeToggleDelay, sp: sp, pc: pc, machineInstruction: machineInstruction, registerTraces: registerTraces, nextAction: nextAction)
  }
}

// MARK: - Subscript access

extension LR35902 {
  // MARK: Subscript access of instructions using LR35902 instruction specifications
  /** 8-bit register subscript. */
  public subscript(numeric: LR35902.Instruction.Numeric) -> UInt8 {
    get { return get(numeric8: numeric) }
    set { set(numeric8: numeric, to: newValue) }
  }
  /** 16-bit register subscript. */
  public subscript(numeric: LR35902.Instruction.Numeric) -> UInt16 {
    get { return get(numeric16: numeric) }
    set { set(numeric16: numeric, to: newValue) }
  }

  public func get(numeric8: LR35902.Instruction.Numeric) -> UInt8 {
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
  public func set(numeric8: LR35902.Instruction.Numeric, to newValue: UInt8) {
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

  public func get(numeric16: LR35902.Instruction.Numeric) -> UInt16 {
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
  public func set(numeric16: LR35902.Instruction.Numeric, to newValue: UInt16) {
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

  /** Resets the register state. */
  public func clear(_ numeric: LR35902.Instruction.Numeric) {
    switch numeric {
    case .a:  a = 0
    case .b:  b = 0
    case .c:  c = 0
    case .d:  d = 0
    case .e:  e = 0
    case .h:  h = 0
    case .l:  l = 0
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

extension LR35902 {
  /** Trace information for a specific register. */
  struct RegisterTrace: Equatable {
    init(sourceLocation: Gameboy.SourceLocation) {
      self.sourceLocation = sourceLocation
      self.loadAddress = nil
    }
    init(loadAddress: LR35902.Address) {
      self.sourceLocation = nil
      self.loadAddress = loadAddress
    }
    init(sourceLocation: Gameboy.SourceLocation, loadAddress: LR35902.Address) {
      self.sourceLocation = sourceLocation
      self.loadAddress = loadAddress
    }

    /** The address from which the value was loaded, if known. */
    let loadAddress: LR35902.Address?

    /** The source location from which this register's value was loaded, if known. */
    let sourceLocation: Gameboy.SourceLocation?
  }
}

extension LR35902: AddressableMemory {
  static let interruptEnableAddress: LR35902.Address = 0xFFFF
  static let interruptFlagAddress: LR35902.Address = 0xFF0F

  func read(from address: Address) -> UInt8 {
    switch address {
    case LR35902.interruptEnableAddress: return interruptEnable.rawValue
    case LR35902.interruptFlagAddress:   return interruptFlag.rawValue
    default: fatalError()
    }
  }

  func write(_ byte: UInt8, to address: Address) {
    switch address {
    case LR35902.interruptEnableAddress: interruptEnable = LR35902.Interrupt(rawValue: byte)
    case LR35902.interruptFlagAddress:   interruptFlag = LR35902.Interrupt(rawValue: byte)
    default: fatalError()
    }
  }

  func sourceLocation(from address: Address) -> Gameboy.SourceLocation {
    return .memory(address)
  }
}
