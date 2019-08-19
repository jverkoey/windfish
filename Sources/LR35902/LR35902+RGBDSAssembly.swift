import Foundation

import FixedWidthInteger

public final class RGBDSAssembly {

  static let maxOpcodeNameLength = 4

  struct Statement: Equatable, CustomStringConvertible {
    let opcode: String
    let operands: [String]?
    init(opcode: String, operands: [String]? = nil) {
      self.opcode = opcode
      self.operands = operands
    }

    var description: String {
      let opcodeName = opcode.padding(toLength: maxOpcodeNameLength, withPad: " ", startingAt: 0)
      if let operands = operands {
        return "\(opcodeName) \(operands.joined(separator: ", "))"
      } else {
        return opcodeName
      }
    }
  }

  static func assembly(for instruction: LR35902.Instruction, with disassembly: LR35902.Disassembly? = nil) -> Statement {
    if let operands = operands(for: instruction, with: disassembly) {
      return Statement(opcode: instruction.spec.opcode, operands: operands)
    } else {
      return Statement(opcode: instruction.spec.opcode)
    }
  }

  public static func assembly(for bytes: [UInt8]) -> String {
    let opcode = "db".padding(toLength: maxOpcodeNameLength, withPad: " ", startingAt: 0)
    let operand = bytes.map { "$\($0.hexString)" }.joined(separator: ", ")
    return "\(opcode) \(operand)"
  }

  public static func text(for bytes: [UInt8]) -> String {
    var accumulator: [String] = []
    var asciiCharacterAccumulator: [UInt8] = []
    for byte in bytes {
      if byte >= 32 && byte <= 126 {
        asciiCharacterAccumulator.append(byte)
      } else {
        if asciiCharacterAccumulator.count > 0 {
          accumulator.append("\"\(String(bytes: asciiCharacterAccumulator, encoding: .ascii)!)\"")
          asciiCharacterAccumulator.removeAll()
        }
        accumulator.append("$\(byte.hexString)")
      }
    }
    if asciiCharacterAccumulator.count > 0 {
      accumulator.append("\"\(String(bytes: asciiCharacterAccumulator, encoding: .ascii)!)\"")
    }
    let opcode = "db".padding(toLength: maxOpcodeNameLength, withPad: " ", startingAt: 0)
    let operand = accumulator.joined(separator: ", ")
    return "\(opcode) \(operand)"
  }

  public static func defaultLabel(at pc: UInt16, in bank: UInt8) -> String? {
    if pc < 0x4000 {
      return "toc_00_\(pc.hexString)"
    } else if pc < 0x8000 {
      return "toc_\(bank.hexString)_\(pc.hexString)"
    } else {
      return nil
    }
  }

  private static func operands(for instruction: LR35902.Instruction, with disassembly: LR35902.Disassembly? = nil) -> [String]? {
    if let disassembly = disassembly {
      switch instruction.spec {
      case let LR35902.InstructionSpec.jp(condition, operand) where operand == .imm16,
           let LR35902.InstructionSpec.call(condition, operand) where operand == .imm16:
        if disassembly.transfersOfControl(at: instruction.imm16!, in: disassembly.cpu.bank) != nil {
          var addressLabel: String
          if let label = disassembly.label(at: instruction.imm16!, in: disassembly.cpu.bank) {
            if let scope = disassembly.contiguousScope(at: disassembly.cpu.pc, in: disassembly.cpu.bank),
              label.starts(with: "\(scope).") {
              addressLabel = label.replacingOccurrences(of: "\(scope).", with: ".")
            } else {
              addressLabel = label
            }
          } else {
            addressLabel = "$\(instruction.imm16!.hexString)"
          }
          if let condition = condition {
            return ["\(condition)", addressLabel]
          } else {
            return [addressLabel]
          }
        }

      case let LR35902.InstructionSpec.jr(condition, operand) where operand == .simm8:
        let jumpAddress = (disassembly.cpu.pc + LR35902.instructionWidths[instruction.spec]!.total).advanced(by: Int(Int8(bitPattern: instruction.imm8!)))
        if disassembly.transfersOfControl(at: jumpAddress, in: disassembly.cpu.bank) != nil {
          var addressLabel: String
          if let label = disassembly.label(at: jumpAddress, in: disassembly.cpu.bank) {
            if let scope = disassembly.contiguousScope(at: disassembly.cpu.pc, in: disassembly.cpu.bank),
              label.starts(with: "\(scope).") {
              addressLabel = label.replacingOccurrences(of: "\(scope).", with: ".")
            } else {
              addressLabel = label
            }
          } else {
            addressLabel = "$\(jumpAddress.hexString)"
          }
          if let condition = condition {
            return ["\(condition)", addressLabel]
          } else {
            return [addressLabel]
          }
        }

      case let LR35902.InstructionSpec.ld(operand1, operand2) where operand1 == .imm16addr:
        var addressLabel: String
        if let label = disassembly.label(at: instruction.imm16!, in: disassembly.cpu.bank) {
          addressLabel = "[\(label)]"
        } else {
          addressLabel = "[$\(instruction.imm16!.hexString)]"
        }
        return [addressLabel, operand(for: instruction, operand: operand2)]

      case let LR35902.InstructionSpec.ld(operand1, operand2) where operand2 == .imm16addr:
        var addressLabel: String
        if let label = disassembly.label(at: instruction.imm16!, in: disassembly.cpu.bank) {
          addressLabel = "[\(label)]"
        } else {
          addressLabel = "[$\(instruction.imm16!.hexString)]"
        }
        return [operand(for: instruction, operand: operand1), addressLabel]

      case let LR35902.InstructionSpec.ld(operand1, operand2) where operand1 == .ffimm8addr:
        var addressLabel: String
        if let name = disassembly.globals[0xFF00 | UInt16(instruction.imm8!)] {
          addressLabel = "[\(name)]"
        } else {
          addressLabel = "[$FF\(instruction.imm8!.hexString)]"
        }
        return [addressLabel, operand(for: instruction, operand: operand2)]

      case let LR35902.InstructionSpec.ld(operand1, operand2) where operand2 == .ffimm8addr:
        var addressLabel: String
        if let name = disassembly.globals[0xFF00 | UInt16(instruction.imm8!)] {
          addressLabel = "[\(name)]"
        } else {
          addressLabel = "[$FF\(instruction.imm8!.hexString)]"
        }
        return [operand(for: instruction, operand: operand1), addressLabel]

      case let LR35902.InstructionSpec.ld(operand1, operand2) where operand2 == .imm16:
        var addressLabel: String
        if let name = disassembly.globals[instruction.imm16!] {
          addressLabel = "\(name)"
        } else {
          addressLabel = "$\(instruction.imm16!.hexString)"
        }
        return [operand(for: instruction, operand: operand1), addressLabel]

      default:
        break
      }
    }
    return operands(for: instruction, spec: instruction.spec)
  }

  private static func operands(for instruction: LR35902.Instruction, spec: LR35902.InstructionSpec) -> [String]? {
    let mirror = Mirror(reflecting: spec)
    guard let operandReflection = mirror.children.first else {
      return nil
    }
    switch operandReflection.value {
    case let childInstruction as LR35902.InstructionSpec:
      return operands(for: instruction, spec: childInstruction)
    case let tuple as (LR35902.Condition?, LR35902.Numeric):
      if let condition = tuple.0 {
        return ["\(condition)", operand(for: instruction, operand: tuple.1)]
      } else {
        return [operand(for: instruction, operand: tuple.1)]
      }
    case let condition as LR35902.Condition:
      return ["\(condition)"]
    case let tuple as (LR35902.Numeric, LR35902.Numeric):
      return [operand(for: instruction, operand: tuple.0), operand(for: instruction, operand: tuple.1)]
    case let tuple as (LR35902.Bit, LR35902.Numeric):
      return ["\(tuple.0.rawValue)", operand(for: instruction, operand: tuple.1)]
    case let operandValue as LR35902.Numeric:
      return [operand(for: instruction, operand: operandValue)]
    case let address as LR35902.RestartAddress:
      return ["\(address)".replacingOccurrences(of: "x", with: "$")]
    default:
      return nil
    }
  }

  private static func operand(for instruction: LR35902.Instruction, operand: LR35902.Numeric) -> String {
    switch operand {
    case .imm8:           return "$\(instruction.imm8!.hexString)"
    case .simm8:
      let byte = instruction.imm8!
      if (byte & UInt8(0x80)) != 0 {
        return "@-$\((0xff - byte + 1 - 2).hexString)"
      } else {
        return "@+$\((byte + 2).hexString)"
      }
    case .imm16:          return "$\(instruction.imm16!.hexString)"
    case .ffimm8addr:  return "[$FF\(instruction.imm8!.hexString)]"
    case .imm16addr:   return "[$\(instruction.imm16!.hexString)]"
    case .bcaddr:            return "[bc]"
    case .deaddr:            return "[de]"
    case .hladdr:            return "[hl]"
    case .ffccaddr:          return "[$ff00+c]"
    case .sp_plus_simm8:
      let signedByte = Int8(bitPattern: instruction.imm8!)
      if signedByte < 0 {
        return "sp-$\((0xff - instruction.imm8! + 1).hexString)"
      } else {
        return "sp+$\(instruction.imm8!.hexString)"
      }
    case .a, .af, .b, .c, .bc, .d, .e, .de, .h, .l, .hl, .sp: return "\(operand)"

    case let .macro(text):
      return text
    case let .arg(number):
      return "\\\(number)"

    case .zeroimm8:
      preconditionFailure("Unable to print out a zero8")
    }
  }
}
