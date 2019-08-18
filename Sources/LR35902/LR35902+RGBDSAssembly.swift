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
      case let LR35902.InstructionSpec.jp(condition, operand) where operand == .immediate16,
           let LR35902.InstructionSpec.call(condition, operand) where operand == .immediate16:
        if disassembly.transfersOfControl(at: instruction.immediate16!, in: disassembly.cpu.bank) != nil {
          var addressLabel: String
          if let label = disassembly.label(at: instruction.immediate16!, in: disassembly.cpu.bank) {
            if let scope = disassembly.contiguousScope(at: disassembly.cpu.pc, in: disassembly.cpu.bank),
              label.starts(with: "\(scope).") {
              addressLabel = label.replacingOccurrences(of: "\(scope).", with: ".")
            } else {
              addressLabel = label
            }
          } else {
            addressLabel = "$\(instruction.immediate16!.hexString)"
          }
          if let condition = condition {
            return ["\(condition)", addressLabel]
          } else {
            return [addressLabel]
          }
        }

      case let LR35902.InstructionSpec.jr(condition, operand) where operand == .immediate8signed:
        let jumpAddress = (disassembly.cpu.pc + LR35902.instructionWidths[instruction.spec]!).advanced(by: Int(Int8(bitPattern: instruction.immediate8!)))
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

      case let LR35902.InstructionSpec.ld(operand1, operand2) where operand1 == .immediate16address:
        var addressLabel: String
        if let label = disassembly.label(at: instruction.immediate16!, in: disassembly.cpu.bank) {
          addressLabel = "[\(label)]"
        } else {
          addressLabel = "[$\(instruction.immediate16!.hexString)]"
        }
        return [addressLabel, operand(for: instruction, operand: operand2)]

      case let LR35902.InstructionSpec.ld(operand1, operand2) where operand2 == .immediate16address:
        var addressLabel: String
        if let label = disassembly.label(at: instruction.immediate16!, in: disassembly.cpu.bank) {
          addressLabel = "[\(label)]"
        } else {
          addressLabel = "[$\(instruction.immediate16!.hexString)]"
        }
        return [operand(for: instruction, operand: operand1), addressLabel]

      case let LR35902.InstructionSpec.ld(operand1, operand2) where operand1 == .ffimmediate8Address:
        var addressLabel: String
        if let name = disassembly.globals[0xFF00 | UInt16(instruction.immediate8!)] {
          addressLabel = "[\(name)]"
        } else {
          addressLabel = "[$FF\(instruction.immediate8!.hexString)]"
        }
        return [addressLabel, operand(for: instruction, operand: operand2)]

      case let LR35902.InstructionSpec.ld(operand1, operand2) where operand2 == .ffimmediate8Address:
        var addressLabel: String
        if let name = disassembly.globals[0xFF00 | UInt16(instruction.immediate8!)] {
          addressLabel = "[\(name)]"
        } else {
          addressLabel = "[$FF\(instruction.immediate8!.hexString)]"
        }
        return [operand(for: instruction, operand: operand1), addressLabel]

      case let LR35902.InstructionSpec.ld(operand1, operand2) where operand2 == .immediate16:
        var addressLabel: String
        if let name = disassembly.globals[instruction.immediate16!] {
          addressLabel = "\(name)"
        } else {
          addressLabel = "$\(instruction.immediate16!.hexString)"
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
    case let tuple as (LR35902.Condition?, LR35902.Operand):
      if let condition = tuple.0 {
        return ["\(condition)", operand(for: instruction, operand: tuple.1)]
      } else {
        return [operand(for: instruction, operand: tuple.1)]
      }
    case let condition as LR35902.Condition:
      return ["\(condition)"]
    case let tuple as (LR35902.Operand, LR35902.Operand):
      return [operand(for: instruction, operand: tuple.0), operand(for: instruction, operand: tuple.1)]
    case let tuple as (LR35902.Bit, LR35902.Operand):
      return ["\(tuple.0.rawValue)", operand(for: instruction, operand: tuple.1)]
    case let operandValue as LR35902.Operand:
      return [operand(for: instruction, operand: operandValue)]
    case let address as LR35902.RestartAddress:
      return ["\(address)".replacingOccurrences(of: "x", with: "$")]
    default:
      return nil
    }
  }

  private static func operand(for instruction: LR35902.Instruction, operand: LR35902.Operand) -> String {
    switch operand {
    case .immediate8:           return "$\(instruction.immediate8!.hexString)"
    case .immediate8signed:
      let byte = instruction.immediate8!
      if (byte & UInt8(0x80)) != 0 {
        return "@-$\((0xff - byte + 1 - 2).hexString)"
      } else {
        return "@+$\((byte + 2).hexString)"
      }
    case .immediate16:          return "$\(instruction.immediate16!.hexString)"
    case .ffimmediate8Address:  return "[$FF\(instruction.immediate8!.hexString)]"
    case .immediate16address:   return "[$\(instruction.immediate16!.hexString)]"
    case .bcAddress:            return "[bc]"
    case .deAddress:            return "[de]"
    case .hlAddress:            return "[hl]"
    case .ffccAddress:          return "[$ff00+c]"
    case .spPlusImmediate8Signed:
      let signedByte = Int8(bitPattern: instruction.immediate8!)
      if signedByte < 0 {
        return "sp-$\((0xff - instruction.immediate8! + 1).hexString)"
      } else {
        return "sp+$\(instruction.immediate8!.hexString)"
      }
    case .a, .af, .b, .c, .bc, .d, .e, .de, .h, .l, .hl, .sp: return "\(operand)"

    case let .macro(text):
      return text
    case let .arg(number):
      return "\\\(number)"

    case .zero8:
      preconditionFailure("Unable to print out a zero8")
    }
  }
}
