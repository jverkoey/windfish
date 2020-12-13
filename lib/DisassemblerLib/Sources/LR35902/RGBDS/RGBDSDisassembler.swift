import Foundation

import FoundationExtensions
import RGBDS

/** Turns LR3902 instructions into RGBDS assembly. */
final class RGBDSDisassembler {

  /** The context within which an instruction should be turned into RGBDS assembly. */
  struct Context {
    let address: LR35902.Address
    let bank: LR35902.Bank
    let disassembly: LR35902.Disassembly
    let argumentString: String?
  }

  /**
   Creates an RGBDS statement for the given instruction.

   - Parameter instruction: Assembly code will be generated for this instruction.
   - Parameter disassembly: Optional additional context for the instruction, such as label names.
   - Parameter argumentString: Overrides any numerical value with the given string. Primarily used for macros.
   */
  static func statement(for instruction: LR35902.Instruction, with context: Context? = nil) -> Statement {
    guard let opcode = LR35902.InstructionSet.opcodeStrings[instruction.spec] else {
      preconditionFailure("Could not find opcode for \(instruction.spec).")
    }

    if let operands = operands(for: instruction, with: context) {
      // Operands should never be empty.
      precondition(operands.first(where: { $0.isEmpty }) == nil)

      return Statement(opcode: opcode, operands: operands)
    }
    return Statement(opcode: opcode)
  }

  // TODO: Continue breaking this apart.
  private static func operands(for instruction: LR35902.Instruction, with context: Context?) -> [String]? {
    guard let context = context else {
      return operands(for: instruction, spec: instruction.spec, with: nil)
    }

    switch instruction.spec {
    case let LR35902.Instruction.Spec.jp(condition, operand) where operand == .imm16,
         let LR35902.Instruction.Spec.call(condition, operand) where operand == .imm16:
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      guard context.disassembly.transfersOfControl(at: immediate, in: context.bank) != nil else {
        break
      }
      let addressLabel = self.addressLabel(context, address: immediate)
      if let condition = condition {
        return ["\(condition)", addressLabel]
      } else {
        return [addressLabel]
      }

    case let LR35902.Instruction.Spec.jr(condition, operand) where operand == .simm8:
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      let jumpAddress = (context.address + LR35902.InstructionSet.widths[instruction.spec]!.total).advanced(by: Int(Int8(bitPattern: immediate)))
      if context.disassembly.transfersOfControl(at: jumpAddress, in: context.bank) != nil {
        let addressLabel = self.addressLabel(context, address: jumpAddress)
        if let condition = condition {
          return ["\(condition)", addressLabel]
        } else {
          return [addressLabel]
        }
      }

    case let LR35902.Instruction.Spec.ld(operand1, operand2) where operand1 == .imm16addr:
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }

      var addressLabel: String
      if let argumentString = context.argumentString {
        addressLabel = argumentString
      } else {
        addressLabel = "[\(prettify(imm16: immediate, with: context))]"
      }
      return [addressLabel, operand(for: instruction, operand: operand2, with: context)]

    case let LR35902.Instruction.Spec.ld(operand1, operand2) where operand2 == .imm16addr:
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }

      var addressLabel: String
      if let argumentString = context.argumentString {
        addressLabel = argumentString
      } else {
        addressLabel = "[\(prettify(imm16: immediate, with: context))]"
      }
      return [operand(for: instruction, operand: operand1, with: context), addressLabel]

    case let LR35902.Instruction.Spec.ld(operand1, operand2) where operand1 == .ffimm8addr:
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }

      var addressLabel: String
      if let argumentString = context.argumentString {
        addressLabel = argumentString
      } else {
        addressLabel = "[\(prettify(imm16: 0xFF00 | UInt16(immediate), with: context))]"
      }
      return [addressLabel, operand(for: instruction, operand: operand2, with: context)]

    case let LR35902.Instruction.Spec.ld(operand1, operand2) where operand2 == .ffimm8addr:
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }

      var addressLabel: String
      if let argumentString = context.argumentString {
        addressLabel = argumentString
      } else {
        addressLabel = "[\(prettify(imm16: 0xFF00 | UInt16(immediate), with: context))]"
      }
      return [operand(for: instruction, operand: operand1, with: context), addressLabel]

    case let LR35902.Instruction.Spec.ld(operand1, operand2) where operand2 == .imm16:
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }

      var addressLabel: String
      // TODO: These are only globals if they're referenced as an address in a subsequent instruction.
      if let argumentString = context.argumentString {
        addressLabel = argumentString
      } else if operand1 == .hl, let name = context.disassembly.globals[immediate]?.name {
        addressLabel = name
      } else {
        addressLabel = "$\(immediate.hexString)"
      }
      return [operand(for: instruction, operand: operand1, with: context), addressLabel]

    default:
      break
    }

    return operands(for: instruction, spec: instruction.spec, with: context)
  }

  private static func typedValue(for imm8: UInt8, with representation: LR35902.Disassembly.Datatype.Representation) -> String {
    switch representation {
    case .binary:
      return RGBDS.NumericPrefix.binary.rawValue + imm8.binaryString
    case .decimal:
      return "\(imm8)"
    case .hexadecimal:
      return RGBDS.asHexString(imm8)
    }
  }

  private static func addressLabel(_ context: Context, address immediate: (UInt16)) -> String {
    // TODO: Why do we always assume that if there's an argument string that we should return it here?
    if let argumentString = context.argumentString {
      return argumentString
    }

    if let label = context.disassembly.label(at: immediate, in: context.bank) {
      if let scope = context.disassembly.labeledContiguousScopes(at: context.address, in: context.bank).first(where: { labeledScope in
        label.starts(with: "\(labeledScope.label).")
      })?.label {
        return label.replacingOccurrences(of: "\(scope).", with: ".")
      } else {
        return label
      }
    }

    return RGBDS.asHexString(immediate)
  }

  private static func typedOperand(for imm8: UInt8, with context: Context?) -> String? {
    guard let context = context else {
      return nil
    }
    let location = LR35902.Cartridge.location(for: context.address, in: context.bank)!
    guard let type = context.disassembly.typeAtLocation[location],
          let dataType = context.disassembly.dataTypes[type] else {
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
  private static func prettify(imm16: UInt16, with context: Context) -> String {
    if let label = context.disassembly.label(at: imm16, in: context.bank) {
      return label
    } else if let global = context.disassembly.globals[imm16] {
      return global.name
    } else {
      return "$\(imm16.hexString)"
    }
  }

  private static func operands(for instruction: LR35902.Instruction, spec: LR35902.Instruction.Spec, with context: Context?) -> [String]? {
    let mirror = Mirror(reflecting: spec)
    guard let operandReflection = mirror.children.first else {
      return nil
    }
    switch operandReflection.value {
    case let childInstruction as LR35902.Instruction.Spec:
      return operands(for: instruction, spec: childInstruction, with: context)
    case let tuple as (LR35902.Instruction.Condition?, LR35902.Instruction.Numeric):
      if let condition = tuple.0 {
        return ["\(condition)", operand(for: instruction, operand: tuple.1, with: context)]
      } else {
        return [operand(for: instruction, operand: tuple.1, with: context)]
      }
    case let condition as LR35902.Instruction.Condition:
      return ["\(condition)"]
    case let tuple as (LR35902.Instruction.Numeric, LR35902.Instruction.Numeric):
      return [operand(for: instruction, operand: tuple.0, with: context),
              operand(for: instruction, operand: tuple.1, with: context)]
    case let tuple as (LR35902.Instruction.Bit, LR35902.Instruction.Numeric):
      return ["\(tuple.0.rawValue)", operand(for: instruction, operand: tuple.1, with: context)]
    case let operandValue as LR35902.Instruction.Numeric:
      return [operand(for: instruction, operand: operandValue, with: context)]
    case let address as LR35902.Instruction.RestartAddress:
      return ["\(address)".replacingOccurrences(of: "x", with: "$")]
    default:
      return nil
    }
  }

  private static func operand(for instruction: LR35902.Instruction, operand: LR35902.Instruction.Numeric, with context: Context?) -> String {
    if let argumentString = context?.argumentString {
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
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      if let typedValue = typedOperand(for: immediate, with: context) {
        return typedValue
      } else {
        return "$\(immediate.hexString)"
      }

    case .simm8:
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      let byte = immediate
      if (byte & UInt8(0x80)) != 0 {
        return "@-$\((0xff - byte + 1 - 2).hexString)"
      } else {
        return "@+$\((byte + 2).hexString)"
      }

    case .imm16:
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      return "$\(immediate.hexString)"

    case .ffimm8addr:
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      return "[$FF\(immediate.hexString)]"

    case .imm16addr:
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      return "[$\(immediate.hexString)]"

    case .bcaddr:            return "[bc]"
    case .deaddr:            return "[de]"
    case .hladdr:            return "[hl]"
    case .ffccaddr:          return "[$ff00+c]"
    case .sp_plus_simm8:
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      let signedByte = Int8(bitPattern: immediate)
      if signedByte < 0 {
        return "sp-$\((0xff - immediate + 1).hexString)"
      } else {
        return "sp+$\(immediate.hexString)"
      }
    case .a, .af, .b, .c, .bc, .d, .e, .de, .h, .l, .hl, .sp: return "\(operand)"

    case .zeroimm8:
      return ""
    }
  }
}
