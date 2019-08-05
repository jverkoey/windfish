import Foundation

extension LR35902 {
  enum Instruction {
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
    case jr(Operand), jr(Condition, Operand)
    case jp(Operand), jp(Condition, Operand)

    // Calls and returns
    case call(Operand), call(Condition, Operand)
    case ret, retC(Condition), reti

    // Restarts
    case rst(RestartAddress)

    // Decimal adjust
    case daa

    // Complement
    case cpl

    // 0xCB prefix
    case cb

    // Invalid opcode
    case invalid
  }
  enum Operand {
    case a, af
    case b, c, bc, bcAddress
    case d, e, de, deAddress
    case h, l, hl, hlAddress

    case sp                   // Stack pointer
    case spPlusImmediate8

    case immediate8, immediate16
    case immediate16address

    case ffimmediate8Address, ffccAddress
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
}
