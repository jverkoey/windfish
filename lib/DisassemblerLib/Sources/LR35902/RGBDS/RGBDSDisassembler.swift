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

  // MARK: - Operand assembly generation

  // TODO: Continue breaking this apart.
  private static func operands(for instruction: LR35902.Instruction, with context: Context?) -> [String]? {
    guard let context = context else {
      return operands(for: instruction, spec: instruction.spec, with: nil)
    }

    // Special case specification handling.
    switch instruction.spec {

    // jp and call should use labels if those labels are transfers of control.
    case let LR35902.Instruction.Spec.jp(condition, operand) where operand == .imm16,
         let LR35902.Instruction.Spec.call(condition, operand) where operand == .imm16:
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      guard context.disassembly.transfersOfControl(at: immediate, in: context.bank) != nil else {
        break // Fall through to the default handler.
      }
      let addressLabel = self.addressLabel(context, address: immediate)
      if let condition = condition {
        return ["\(condition)", addressLabel]
      }

      return [addressLabel]

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

    // Generic case specification handling.
    return operands(for: instruction, spec: instruction.spec, with: context)
  }

  /**
   Generic resolution of operands to RGBDS assembly.

   No specification assumptions are made here; this handler is intentionally a generic catch-all.

   This method can recurse as needed when specifications are nested.

   - Parameter instruction: The instruction whose operands are to be returned.
   - Parameter spec: The spec being used to extract the operands. May be a nested spec of the instruction's spec.
   */
  private static func operands(for instruction: LR35902.Instruction, spec: LR35902.Instruction.Spec, with context: Context?) -> [String]? {
    let mirror = Mirror(reflecting: spec)
    guard let operandReflection = mirror.children.first else {
      return nil  // This specification has no operands.
    }

    // This switch is a glorified if/else statement, so the most frequent combinations of operands are evaluated first.
    switch operandReflection.value {

    case let tuple as (LR35902.Instruction.Numeric, LR35902.Instruction.Numeric):
      return [
        operand(for: instruction, operand: tuple.0, with: context),
        operand(for: instruction, operand: tuple.1, with: context)
      ]

    case let operandValue as LR35902.Instruction.Numeric:
      return [operand(for: instruction, operand: operandValue, with: context)]

    case Optional<Any>.none:
      return nil

    case let childInstruction as LR35902.Instruction.Spec:
      return operands(for: instruction, spec: childInstruction, with: context)

    case let condition as LR35902.Instruction.Condition:
      return ["\(condition)"]

    case let tuple as (LR35902.Instruction.Bit, LR35902.Instruction.Numeric):
      return [
        "\(tuple.0.rawValue)",
        operand(for: instruction, operand: tuple.1, with: context)
      ]

    case let address as LR35902.Instruction.RestartAddress:
      // Restart addresses use an x prefix because dollar signs can't be represented in Swift enum case names, but the
      // addresses are technically hexadecimal.
      return ["\(address)".replacingOccurrences(of: "x", with: RGBDS.NumericPrefix.hexadecimal.rawValue)]

    case let tuple as (LR35902.Instruction.Condition?, LR35902.Instruction.Numeric):
      let numericOperand = operand(for: instruction, operand: tuple.1, with: context)

      if let condition = tuple.0 {
        return ["\(condition)", numericOperand]
      }

      return [numericOperand]

    default:
      preconditionFailure("Unhandled operand type")
    }
  }

  private static func operand(for instruction: LR35902.Instruction, operand: LR35902.Instruction.Numeric, with context: Context?) -> String {
    if let argumentString = context?.argumentString {
      switch operand {
      case .imm16, .imm8, .imm16addr, .simm8, .sp_plus_simm8, .ffimm8addr:
        // We only replace immediate values with argument strings.
        // TODO: This is overly restrictive because arguments can technically be used for anything.
        return argumentString
      default:
        break
      }
    }

    // This switch is a glorified if/else statement, so the most frequent combinations of operands are evaluated first.
    switch operand {
    case .a, .af, .b, .c, .bc, .d, .e, .de, .h, .l, .hl, .sp:
      return "\(operand)"

    case .hladdr:
      return "[hl]"

    case .imm8:
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }

      if let typedValue = typedOperand(for: immediate, with: context) {
        return typedValue
      }

      return RGBDS.asHexString(immediate)

    case .simm8:
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      if let context = context {
        let jumpAddress = (context.address + LR35902.InstructionSet.widths[instruction.spec]!.total).advanced(by: Int(Int8(bitPattern: immediate)))
        if context.disassembly.transfersOfControl(at: jumpAddress, in: context.bank) != nil {
          return self.addressLabel(context, address: jumpAddress)
        }
      }

      let byte = immediate
      if (byte & UInt8(0x80)) != 0 {
        return "@-" + RGBDS.asHexString(0xff - byte + 1 - 2)
      }

      return "@+" + RGBDS.asHexString(byte + 2)

    case .deaddr:
      return "[de]"

    case .imm16addr:
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      if let context = context {
        // Always rpresent imm16addr as a label if possible.
        return "[\(prettify(imm16: immediate, with: context))]"
      }
      return RGBDS.asHexAddressString(immediate)

    case .imm16:
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      return RGBDS.asHexString(immediate)

    case .ffccaddr:
      return "[$ff00+c]"

    case .sp_plus_simm8:
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      let signedByte = Int8(bitPattern: immediate)
      if signedByte < 0 {
        return "sp-$\((0xff - immediate + 1).hexString)"
      }

      return "sp+$\(immediate.hexString)"

    case .bcaddr:
      return "[bc]"

    case .ffimm8addr:
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      return "[$FF\(immediate.hexString)]"

    case .zeroimm8:
      preconditionFailure("This operand is not meant to be represented in source")
    }
  }

  /// Returns one of a label, a global, or a hexadecimal representation of a given imm16 value.
  private static func prettify(imm16: UInt16, with context: Context) -> String {
    if let label = context.disassembly.label(at: imm16, in: context.bank) {
      return label
    } else if let global = context.disassembly.globals[imm16] {
      return global.name
    } else {
      return RGBDS.asHexString(imm16)
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
}
