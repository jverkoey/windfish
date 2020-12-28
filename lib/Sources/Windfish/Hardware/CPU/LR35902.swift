import Foundation

/**
 A representation of the LR35902 CPU at a specific moment.

 All registers are optional, allowing for the representation of registers being in an unknown state in order to
 support emulation of a block of instructions that might be reached from unknown locations or a variety of states.
 */
public final class LR35902 {
  public typealias Address = UInt16

  public final class MachineInstruction {
    enum MicroCodeResult {
      case continueExecution
      case fetchNext
      case fetchPrefix
    }
    typealias MicroCode = (LR35902, AddressableMemory, Int) -> MicroCodeResult

    struct LoadedInstruction {
      let spec: Instruction.Spec
      let microcode: MicroCode
      let sourceLocation: Disassembler.SourceLocation
    }

    internal init() {}

    internal init(spec: LR35902.Instruction.Spec, sourceLocation: Disassembler.SourceLocation) {
      self.loaded = LoadedInstruction(spec: spec,
                                      microcode: InstructionSet.microcode(for: spec, sourceLocation: sourceLocation),
                                      sourceLocation: sourceLocation)
    }

    var loaded: LoadedInstruction? = nil
    var cycle: Int = 0

    public func sourceAddressAndBank() -> (address: LR35902.Address, bank: Gameboy.Cartridge.Bank)? {
      guard case let .cartridge(sourceLocation) = loaded?.sourceLocation else {
        return nil
      }
      return Gameboy.Cartridge.addressAndBank(from: sourceLocation)
    }
  }

  public var state = State()
  public struct State {
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
    var interruptEnable: LR35902.Instruction.Interrupt = []

    /** Enabled bits represent a requested interrupt. */
    var interruptFlag: LR35902.Instruction.Interrupt = []

    /**
     The halt status.

     When true, the CPU will stop executing instructions until the next interrupt occurs.
     */
    public var halted: Bool = false

    /** Indicates whether the CPU is fetching and executing instructions. */
    public func isRunning() -> Bool {
      return !halted
    }

    /**
     If greater than zero, then this value will be decremented on each machine cycle until it is less then or equal to 0,
     at which point ime will be enabled.
     */
    var imeScheduledCyclesRemaining: Int = 0

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
    public var registerTraces: [LR35902.Instruction.Numeric: RegisterTrace] = [:]
  }

  var nextAction: MachineInstruction.MicroCodeResult = .fetchNext

  /** Initializes the state with boot values. */
  public init() {}

  /** Initializes the state with specific values. */
  public init(a: UInt8 = 0, b: UInt8 = 0, c: UInt8 = 0, d: UInt8 = 0, e: UInt8 = 0, h: UInt8 = 0, l: UInt8 = 0, fzero: Bool = false, fsubtract: Bool = false, fhalfcarry: Bool = false, fcarry: Bool = false, sp: UInt16 = 0, pc: LR35902.Address = 0, registerTraces: [LR35902.Instruction.Numeric : LR35902.RegisterTrace] = [:]) {
    self.state = State(a: a, b: b, c: c, d: d, e: e, h: h, l: l, fzero: fzero, fsubtract: fsubtract, fhalfcarry: fhalfcarry, fcarry: fcarry, sp: sp, pc: pc)
  }

  public static func zeroed() -> LR35902 {
    return LR35902(a: 0, b: 0, c: 0, d: 0, e: 0, h: 0, l: 0, fzero: false, fsubtract: false, fhalfcarry: false, fcarry: false, sp: 0, pc: 0, registerTraces: [:])
  }
}

// MARK: - Subscript access

extension LR35902.State {
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
  public mutating func set(numeric8: LR35902.Instruction.Numeric, to newValue: UInt8) {
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
  public mutating func set(numeric16: LR35902.Instruction.Numeric, to newValue: UInt16) {
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
  public mutating func clear(_ numeric: LR35902.Instruction.Numeric) {
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
  public struct RegisterTrace: Equatable {
    public init(sourceLocation: Disassembler.SourceLocation) {
      self.sourceLocation = sourceLocation
      self.loadAddress = nil
    }
    public init(loadAddress: LR35902.Address) {
      self.sourceLocation = nil
      self.loadAddress = loadAddress
    }
    public init(sourceLocation: Disassembler.SourceLocation, loadAddress: LR35902.Address) {
      self.sourceLocation = sourceLocation
      self.loadAddress = loadAddress
    }

    /** The address from which the value was loaded, if known. */
    public let loadAddress: LR35902.Address?

    /** The source location from which this register's value was loaded, if known. */
    public let sourceLocation: Disassembler.SourceLocation?
  }
}

extension LR35902: AddressableMemory {
  static let interruptEnableAddress: LR35902.Address = 0xFFFF
  static let interruptFlagAddress: LR35902.Address = 0xFF0F

  public func read(from address: Address) -> UInt8 {
    switch address {
    case LR35902.interruptEnableAddress: return state.interruptEnable.rawValue
    case LR35902.interruptFlagAddress:   return state.interruptFlag.rawValue
    default: fatalError()
    }
  }

  public func write(_ byte: UInt8, to address: Address) {
    switch address {
    case LR35902.interruptEnableAddress: state.interruptEnable = LR35902.Instruction.Interrupt(rawValue: byte)
    case LR35902.interruptFlagAddress:   state.interruptFlag = LR35902.Instruction.Interrupt(rawValue: byte)
    default: fatalError()
    }
  }

  public func sourceLocation(from address: Address) -> Disassembler.SourceLocation {
    return .memory(address)
  }
}
