import Foundation

extension LR35902 {
  struct CPUState {
    enum RegisterValue<T: BinaryInteger>: Equatable {
      case variable(LR35902.Address)
      case value(T)
    }
    struct RegisterState<T: BinaryInteger>: Equatable {
      let value: RegisterValue<T>
      let sourceLocation: LR35902.Cartridge.Location
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
    var next: [LR35902.Cartridge.Location] = []
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
}
