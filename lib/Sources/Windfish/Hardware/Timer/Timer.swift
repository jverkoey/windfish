import Foundation

// References:
// - https://gbdev.gg8.se/wiki/articles/Timer_Obscure_Behaviour
// - https://github.com/AntonioND/giibiiadvance/raw/master/docs/TCAGBD.pdf

public final class Timer {
  static let timerRegion: ClosedRange<LR35902.Address> = 0xFF04...0xFF07

  enum TimerAddress: LR35902.Address {
    case DIV  = 0xFF04
    case TIMA = 0xFF05
    case TMA  = 0xFF06
    case TAC  = 0xFF07
  }

  // MARK: - DIV (0xFF04)

  /** Divider register. */
  var div: UInt8 {
    return UInt8(truncatingIfNeeded: clock >> 8)
  }
  private var clock: UInt16 = 0xABCC

  // MARK: - TIMA (0xFF05)

  /** Timer counter; when this overflows, a timer interrupt is generated. */
  var tima: UInt8 = 0

  enum TimaState {
    case running
    case reloading
    case reloaded
  }
  private var timaState: TimaState = .running

  // MARK: - TMA (0xFF06)

  /** Timer modulo. After TIMA overflows, it is loaded with this value. */
  var tma: UInt8 = 0

  // MARK: - TAC (0xFF07)

  /** Timer control. Controls activation and speed of the timer. */
  var tac: UInt8 {
    get {
      return (timerEnabled ? 0b100 : 0) | inputClock.rawValue
    }
    set {
      timerEnabled = (newValue & 0b100) != 0
      inputClock = InputClock(rawValue: newValue & 0b11)!
    }
  }
  /** Whether or not the timer is enabled. */
  var timerEnabled = false

  enum InputClock: UInt8 {
    case hz4096   = 0b00
    case hz262144 = 0b01
    case hz65536  = 0b10
    case hz16384  = 0b11
  }
  var inputClock: InputClock = .hz4096
}

extension Timer {
  static let clockBit: [InputClock: UInt16] = [
    .hz4096: 1 << 9,
    .hz262144: 1 << 3,
    .hz65536: 1 << 5,
    .hz16384: 1 << 7,
  ]
  public func advance(memory: AddressableMemory) {
    if timaState == .reloaded {
      timaState = .running
    } else if timaState == .reloading {
      var interruptFlag = LR35902.Instruction.Interrupt(rawValue: memory.read(from: LR35902.interruptFlagAddress))
      interruptFlag.insert(.timer)
      memory.write(interruptFlag.rawValue, to: LR35902.interruptFlagAddress)
      timaState = .reloaded
    }

    let oldClock = clock
    clock &+= 4
    if timerEnabled && fallingEdge(oldClock: oldClock, clock: clock) {
      incTima()
    }
  }

  private func incTima() {
    tima &+= 1
    if tima == 0 {
      tima = tma  // Restart the counter with the modulo.
      timaState = .reloading
    }
  }

  private func fallingEdge(oldClock: UInt16, clock: UInt16) -> Bool {
    let bit = Timer.clockBit[inputClock]!
    return ((oldClock & bit) != 0) && ((clock & bit) == 0)
  }
}

extension Timer: AddressableMemory {

  public func read(from address: LR35902.Address) -> UInt8 {
    switch TimerAddress(rawValue: address)! {
    case .DIV:  return div
    case .TIMA:
      if timaState == .reloading {
        return 0
      }
      return tima
    case .TMA:  return tma
    case .TAC:  return tac
    }
  }

  public func write(_ byte: UInt8, to address: LR35902.Address) {
    switch TimerAddress(rawValue: address)! {
    case .DIV:
      clock = 0

    case .TIMA:
      if timaState == .reloaded {
        return
      }
      tima = byte

    case .TMA:
      tma = byte
      if timaState != .running {
        tima = tma
      }

    case .TAC:
      let old = timerEnabled && (clock & Timer.clockBit[inputClock]!) != 0
      tac = byte
      if old && (!timerEnabled || (clock & Timer.clockBit[inputClock]!) != 0) {
        incTima()
      }
    }
  }

  public func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
    return .memory(address)
  }
}
