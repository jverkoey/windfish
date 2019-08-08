import Foundation

extension LR35902 {
  enum InstructionSpec {
    // Loads
    case ld(Operand, Operand)
    case ldi(Operand, Operand), ldd(Operand, Operand)

    // Stack manipulation
    case push(Operand), pop(Operand)

    // 8- and 16-bit arithmetic
    case add(Operand), add(Operand, Operand), adc(Operand)
    case sub(Operand), sub(Operand, Operand), sbc(Operand)
    case and(Operand), or(Operand), xor(Operand)
    case cp(Operand)
    case inc(Operand), dec(Operand)

    // Carry flag
    case ccf, scf

    // Program execution
    case nop, stop, halt

    // Interrupts
    case di, ei

    // Rotates and shifts
    case rla, rlca
    case rra, rrca

    // Jumps
    case jr(Operand, Condition? = nil)
    case jp(Operand, Condition? = nil)

    // Calls and returns
    case call(Operand, Condition? = nil)
    case ret(Condition? = nil), reti

    // Restarts
    case rst(RestartAddress)

    // Decimal adjust
    case daa

    // Complement
    case cpl

    // 0xCB prefix
    case cb
    case rlc(Operand), rrc(Operand)
    case rl(Operand), rr(Operand)
    case sla(Operand), sra(Operand)
    case swap(Operand), srl(Operand)

    case bit(Bit, Operand), res(Bit, Operand), set(Bit, Operand)

    // Invalid opcode
    case invalid(UInt8)

    var name: String {
      if let child = Mirror(reflecting: self).children.first {
        return child.label!
      } else {
        return "\("\(self)".split(separator: ".").last!)"
      }
    }
    var operands: String {
      return String(describing: Mirror(reflecting: self).children.first!.value)
    }
    var operandWidth: UInt16 {
      let mirror = Mirror(reflecting: self)
      guard let operands = mirror.children.first else {
        return 0
      }
      switch operands.value {
      case let tuple as (Operand, Condition?):
        return tuple.0.byteWidth
      case let tuple as (Operand, Operand):
        return tuple.0.byteWidth + tuple.1.byteWidth
      case let operand as Operand:
        return operand.byteWidth
      default:
        return 0
      }
    }
  }
  enum Operand {
    case a, af
    case b, c, bc, bcAddress
    case d, e, de, deAddress
    case h, l, hl, hlAddress

    case sp
    case spPlusImmediate8Signed

    case immediate8, immediate8signed, immediate16
    case immediate16address

    case ffimmediate8Address, ffccAddress

    var byteWidth: UInt16 {
      switch self {
      case .spPlusImmediate8Signed, .immediate8, .immediate8signed, .ffimmediate8Address: return 1
      case .immediate16, .immediate16address: return 2
      default: return 0
      }
    }
  }
  enum Condition {
    case nz
    case z
    case nc
    case c
  }
  enum RestartAddress {
    case x00
    case x08
    case x10
    case x18
    case x20
    case x28
    case x30
    case x38
  }
  enum Bit: UInt8 {
    case b0 = 0
    case b1 = 1
    case b2 = 2
    case b3 = 3
    case b4 = 4
    case b5 = 5
    case b6 = 6
    case b7 = 7
  }
}
