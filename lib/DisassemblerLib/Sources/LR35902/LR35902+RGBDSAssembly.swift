import Foundation

import FixedWidthInteger

public final class RGBDSAssembly {

  static let maxOpcodeNameLength = 4

  public struct Statement: Equatable, CustomStringConvertible {
    public let opcode: String
    public let operands: [String]?
    public let comments: String?
    public init(opcode: String, operands: [String]? = nil, comments: String? = nil) {
      self.opcode = opcode
      self.operands = operands
      self.comments = comments
    }

    public var description: String {
      let opcodeName = opcode.padding(toLength: maxOpcodeNameLength, withPad: " ", startingAt: 0)
      if let operands = operands {
        return "\(opcodeName) \(operands.joined(separator: ", "))"
      } else {
        return opcodeName
      }
    }

    public func attributedString(attributes: [NSAttributedString.Key : Any],
                                 opcodeAttributes: [NSAttributedString.Key : Any],
                                 operandAttributes: [NSAttributedString.Key : Any]) -> NSAttributedString {
      let string = NSMutableAttributedString()
      let opcodeName = opcode.padding(toLength: maxOpcodeNameLength, withPad: " ", startingAt: 0)
      string.append(NSAttributedString(string: opcodeName, attributes: opcodeAttributes))
      if let operands = operands {
        string.append(NSAttributedString(string: " ", attributes: attributes))
        string.append(NSAttributedString(string: operands.joined(separator: ", "), attributes: operandAttributes))
      }
      return string
    }
  }

  static func assembly(for instruction: LR35902.Instruction, with disassembly: LR35902.Disassembly? = nil, argumentString: String? = nil) -> Statement {
    if let operands = operands(for: instruction, with: disassembly, argumentString: argumentString) {
      return Statement(opcode: LR35902.Instruction.opcodes[instruction.spec]!, operands: operands.filter { $0.count > 0 })
    } else {
      return Statement(opcode: LR35902.Instruction.opcodes[instruction.spec]!)
    }
  }

  public static func statement(for bytes: [UInt8]) -> Statement {
    return Statement(opcode: "db", operands: bytes.map { "$\($0.hexString)" })
  }

  public static func statement(for value: String) -> Statement {
    return Statement(opcode: "db", operands: [value])
  }

  private static func flatten(asciiCodes: [UInt8], characterMap: [UInt8: String]) -> String {
    return asciiCodes.map {
      if let string = characterMap[$0] {
        return string
      } else {
        return String(bytes: [$0], encoding: .ascii)!
      }
    }.joined()
  }

  public static func textLine(for bytes: [UInt8], characterMap: [UInt8: String], address: LR35902.Address) -> LR35902.Disassembly.Line {
    var accumulator: [String] = []
    var asciiCharacterAccumulator: [UInt8] = []
    for byte in bytes {
      if (byte >= 32 && byte <= 126) || characterMap[byte] != nil {
        asciiCharacterAccumulator.append(byte)
      } else {
        if asciiCharacterAccumulator.count > 0 {
          accumulator.append("\"\(flatten(asciiCodes: asciiCharacterAccumulator, characterMap: characterMap))\"")
          asciiCharacterAccumulator.removeAll()
        }
        accumulator.append("$\(byte.hexString)")
      }
    }
    if asciiCharacterAccumulator.count > 0 {
      accumulator.append("\"\(flatten(asciiCodes: asciiCharacterAccumulator, characterMap: characterMap))\"")
    }
    return LR35902.Disassembly.Line(semantic: .text(Statement(opcode: "db", operands: accumulator)), address: address)
  }

  private static func typedValue(for imm8: UInt8, with representation: LR35902.Disassembly.Datatype.Representation) -> String {
    switch representation {
    case .binary:
      return "%\(imm8.binaryString)"
    case .decimal:
      return "\(imm8)"
    case .hexadecimal:
      return "$\(imm8.hexString)"
    }
  }

  private static func typedOperand(for imm8: UInt8, with disassembly: LR35902.Disassembly?) -> String? {
    guard let disassembly = disassembly else {
      return nil
    }
    let location = LR35902.cartridgeLocation(for: disassembly.cpu.pc, in: disassembly.cpu.bank)!
    guard let type = disassembly.typeAtLocation[location],
      let dataType = disassembly.dataTypes[type] else {
      return nil
    }
    switch dataType.interpretation {
    case .bitmask:
      var namedValues: UInt8 = 0
      let bitmaskValues = dataType.namedValues.filter { value, _ in
        if imm8 == 0 {
          return value == 0
        }
        if value != 0 && (imm8 & value) == value {
          namedValues = namedValues | value
          return true
        }
        return false
      }.values
      var parts = bitmaskValues.sorted()

      if namedValues != imm8 {
        let remainingBits = imm8 & ~(namedValues)
        parts.append(typedValue(for: remainingBits, with: dataType.representation))
      }
      return parts.joined(separator: " | ")

    case .enumerated:
      let possibleValues = dataType.namedValues.filter { value, _ in value == imm8 }.values
      precondition(possibleValues.count <= 1, "Multiple possible values found.")
      if let value = possibleValues.first {
        return value
      }

    default:
      break
    }

    // Fall-through case.
    return typedValue(for: imm8, with: dataType.representation)
  }

  /// Returns one of a label, a global, or a hexadecimal representation of a given imm16 value.
  private static func prettify(imm16: UInt16, with disassembly: LR35902.Disassembly) -> String {
    if let label = disassembly.label(at: imm16, in: disassembly.cpu.bank) {
      return label
    } else if let global = disassembly.globals[imm16] {
      return global.name
    } else {
      return "$\(imm16.hexString)"
    }
  }

  private static func operands(for instruction: LR35902.Instruction, with disassembly: LR35902.Disassembly? = nil, argumentString: String?) -> [String]? {
    if let disassembly = disassembly {
      switch instruction.spec {
      case let LR35902.Instruction.Spec.jp(condition, operand) where operand == .imm16,
           let LR35902.Instruction.Spec.call(condition, operand) where operand == .imm16:
        if disassembly.transfersOfControl(at: instruction.imm16!, in: disassembly.cpu.bank) != nil {
          var addressLabel: String
          if let argumentString = argumentString {
            addressLabel = argumentString
          } else if let label = disassembly.label(at: instruction.imm16!, in: disassembly.cpu.bank) {
            if let scope = disassembly.labeledContiguousScopes(at: disassembly.cpu.pc, in: disassembly.cpu.bank).first(where: { labeledScope in
              label.starts(with: "\(labeledScope.label).")
            })?.label {
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

      case let LR35902.Instruction.Spec.jr(condition, operand) where operand == .simm8:
        let jumpAddress = (disassembly.cpu.pc + LR35902.Instruction.widths[instruction.spec]!.total).advanced(by: Int(Int8(bitPattern: instruction.imm8!)))
        if disassembly.transfersOfControl(at: jumpAddress, in: disassembly.cpu.bank) != nil {
          var addressLabel: String
          if let argumentString = argumentString {
            addressLabel = argumentString
          } else if let label = disassembly.label(at: jumpAddress, in: disassembly.cpu.bank) {
            if let scope = disassembly.labeledContiguousScopes(at: disassembly.cpu.pc, in: disassembly.cpu.bank).first(where: { labeledScope in
              label.starts(with: "\(labeledScope.label).")
            })?.label {
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

      case let LR35902.Instruction.Spec.ld(operand1, operand2) where operand1 == .imm16addr:
        var addressLabel: String
        if let argumentString = argumentString {
          addressLabel = argumentString
        } else {
          addressLabel = "[\(prettify(imm16: instruction.imm16!, with: disassembly))]"
        }
        return [addressLabel, operand(for: instruction, operand: operand2, with: disassembly, argumentString: argumentString)]

      case let LR35902.Instruction.Spec.ld(operand1, operand2) where operand2 == .imm16addr:
        var addressLabel: String
        if let argumentString = argumentString {
          addressLabel = argumentString
        } else {
          addressLabel = "[\(prettify(imm16: instruction.imm16!, with: disassembly))]"
        }
        return [operand(for: instruction, operand: operand1, with: disassembly, argumentString: argumentString), addressLabel]

      case let LR35902.Instruction.Spec.ld(operand1, operand2) where operand1 == .ffimm8addr:
        var addressLabel: String
        if let argumentString = argumentString {
          addressLabel = argumentString
        } else {
          addressLabel = "[\(prettify(imm16: 0xFF00 | UInt16(instruction.imm8!), with: disassembly))]"
        }
        return [addressLabel, operand(for: instruction, operand: operand2, with: disassembly, argumentString: argumentString)]

      case let LR35902.Instruction.Spec.ld(operand1, operand2) where operand2 == .ffimm8addr:
        var addressLabel: String
        if let argumentString = argumentString {
          addressLabel = argumentString
        } else {
          addressLabel = "[\(prettify(imm16: 0xFF00 | UInt16(instruction.imm8!), with: disassembly))]"
        }
        return [operand(for: instruction, operand: operand1, with: disassembly, argumentString: argumentString), addressLabel]

      case let LR35902.Instruction.Spec.ld(operand1, operand2) where operand2 == .imm16:
        var addressLabel: String
        // TODO: These are only globals if they're referenced as an address in a subsequent instruction.
        if let argumentString = argumentString {
          addressLabel = argumentString
        } else if operand1 == .hl, let name = disassembly.globals[instruction.imm16!]?.name {
          addressLabel = name
        } else {
          addressLabel = "$\(instruction.imm16!.hexString)"
        }
        return [operand(for: instruction, operand: operand1, with: disassembly, argumentString: argumentString), addressLabel]

      default:
        break
      }
    }
    return operands(for: instruction, spec: instruction.spec, with: disassembly, argumentString: argumentString)
  }

  private static func operands(for instruction: LR35902.Instruction, spec: LR35902.Instruction.Spec, with disassembly: LR35902.Disassembly?, argumentString: String?) -> [String]? {
    let mirror = Mirror(reflecting: spec)
    guard let operandReflection = mirror.children.first else {
      return nil
    }
    switch operandReflection.value {
    case let childInstruction as LR35902.Instruction.Spec:
      return operands(for: instruction, spec: childInstruction, with: disassembly, argumentString: argumentString)
    case let tuple as (LR35902.Instruction.Condition?, LR35902.Instruction.Numeric):
      if let condition = tuple.0 {
        return ["\(condition)", operand(for: instruction, operand: tuple.1, with: disassembly, argumentString: argumentString)]
      } else {
        return [operand(for: instruction, operand: tuple.1, with: disassembly, argumentString: argumentString)]
      }
    case let condition as LR35902.Instruction.Condition:
      return ["\(condition)"]
    case let tuple as (LR35902.Instruction.Numeric, LR35902.Instruction.Numeric):
      return [operand(for: instruction, operand: tuple.0, with: disassembly, argumentString: argumentString),
              operand(for: instruction, operand: tuple.1, with: disassembly, argumentString: argumentString)]
    case let tuple as (LR35902.Instruction.Bit, LR35902.Instruction.Numeric):
      return ["\(tuple.0.rawValue)", operand(for: instruction, operand: tuple.1, with: disassembly, argumentString: argumentString)]
    case let operandValue as LR35902.Instruction.Numeric:
      return [operand(for: instruction, operand: operandValue, with: disassembly, argumentString: argumentString)]
    case let address as LR35902.Instruction.RestartAddress:
      return ["\(address)".replacingOccurrences(of: "x", with: "$")]
    default:
      return nil
    }
  }

  private static func operand(for instruction: LR35902.Instruction, operand: LR35902.Instruction.Numeric, with disassembly: LR35902.Disassembly?, argumentString: String?) -> String {
    if let argumentString = argumentString {
      switch operand {
      case LR35902.Instruction.Numeric.imm16,
           LR35902.Instruction.Numeric.imm8,
           LR35902.Instruction.Numeric.imm16addr,
           LR35902.Instruction.Numeric.simm8,
           LR35902.Instruction.Numeric.sp_plus_simm8,
           LR35902.Instruction.Numeric.ffimm8addr:
        return argumentString
      default:
        break
      }
    }
    switch operand {
    case .imm8:
      if let typedValue = typedOperand(for: instruction.imm8!, with: disassembly) {
        return typedValue
      } else {
        return "$\(instruction.imm8!.hexString)"
      }
    case .simm8:
      let byte = instruction.imm8!
      if (byte & UInt8(0x80)) != 0 {
        return "@-$\((0xff - byte + 1 - 2).hexString)"
      } else {
        return "@+$\((byte + 2).hexString)"
      }
    case .imm16:             return "$\(instruction.imm16!.hexString)"
    case .ffimm8addr:        return "[$FF\(instruction.imm8!.hexString)]"
    case .imm16addr:         return "[$\(instruction.imm16!.hexString)]"
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

    case .zeroimm8:
      return ""
    }
  }
}
