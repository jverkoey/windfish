import Foundation
import CPU

extension LR35902.Instruction {
  /** The specification for an LR35902's instruction set. */
  public indirect enum Spec: CPU.InstructionSpec {
    public typealias WidthType = UInt16

    // Loads
    case ld(Numeric, Numeric), ldi(Numeric, Numeric), ldd(Numeric, Numeric)

    // Stack manipulation
    case push(Numeric), pop(Numeric)

    // 8- and 16-bit arithmetic
    case add(Numeric), add(Numeric, Numeric), adc(Numeric)
    case sub(Numeric), sub(Numeric, Numeric), sbc(Numeric)
    case and(Numeric), or(Numeric), xor(Numeric)
    case cp(Numeric)
    case inc(Numeric), dec(Numeric)

    // Carry flag
    case ccf, scf

    // Program execution
    case nop, stop(Numeric), halt

    // Interrupts
    case di, ei

    // Rotates and shifts
    case rla, rlca
    case rra, rrca

    // Jumps
    case jr(Condition? = nil, Numeric)
    case jp(Condition? = nil, Numeric)

    // Calls and returns
    case call(Condition? = nil, Numeric)
    case ret(Condition? = nil), reti

    // Restarts
    case rst(RestartAddress)

    // Decimal adjust
    case daa

    // Complement
    case cpl

    case prefix(PrefixTable)

    // 0xCB prefix
    case cb(Spec)
    case rlc(Numeric), rrc(Numeric)
    case rl(Numeric), rr(Numeric)
    case sla(Numeric), sra(Numeric)
    case swap(Numeric), srl(Numeric)
    case bit(Bit, Numeric), res(Bit, Numeric), set(Bit, Numeric)

    // Invalid opcode
    case invalid
  }

  public enum PrefixTable: Hashable {
    case cb
  }

  /** Numeric operands in LR35902's instruction set. */
  public enum Numeric: Hashable, InstructionOperandWithBinaryFootprint {
    case a, af
    case b, c, bc, bcaddr
    case d, e, de, deaddr
    case h, l, hl, hladdr

    case sp, sp_plus_simm8

    case imm8, simm8, imm16
    case imm16addr

    case ffimm8addr, ffccaddr

    case zeroimm8  // Used solely as a placeholder for stop's extra null byte

    public static let registers8: Set<LR35902.Instruction.Numeric> = Set([
      .a,
      .b, .c,
      .d, .e,
      .h, .l,
    ])

    public static let registers16: Set<LR35902.Instruction.Numeric> = Set([
      .bc,
      .de,
      .hl,
      .sp,
    ])

    public var width: Int {
      switch self {
      case .sp_plus_simm8, .imm8, .simm8, .ffimm8addr, .zeroimm8: return 1
      case .imm16, .imm16addr: return 2
      default: return 0
      }
    }
  }

  /// Possible conditions in LR35902's instruction set.
  public enum Condition {
    case nz
    case z
    case nc
    case c
  }

  /// Possible rst addresses in LR35902's instruction set.
  public enum RestartAddress: UInt8 {
    case x00 = 0x00
    case x08 = 0x08
    case x10 = 0x10
    case x18 = 0x18
    case x20 = 0x20
    case x28 = 0x28
    case x30 = 0x30
    case x38 = 0x38
  }

  /// Possible bits in LR35902's instruction set.
  public enum Bit: UInt8 {
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
