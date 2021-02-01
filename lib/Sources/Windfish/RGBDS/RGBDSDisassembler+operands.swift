import Foundation

import RGBDS

extension RGBDSDisassembler {
  /**
   Transforms an instruction's operands to their RGBDS assembly equivalent.

   This is the entry point for disassembling an instruction's operands.
   */
  static func operands(for instruction: LR35902.Instruction, with context: Context?) -> [String]? {
    guard let context = context else {
      return operands(for: instruction, spec: instruction.spec, with: nil)
    }

    // Special case specification handling.
    switch instruction.spec {

    case .stop:
      // STOP always has a ghost operand representing a nop, but it's not actually represented in source.
      return []

    // jp and call prefer labels if those labels are transfers of control.
    case let LR35902.Instruction.Spec.jp(condition, operand) where operand == .imm16,
         let LR35902.Instruction.Spec.call(condition, operand) where operand == .imm16:
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      guard context.disassembly.lastBankRouter?.transfersOfControl(at: Cartridge.Location(address: immediate, bank: context.bank)) != nil else {
        break // Fall through to the default handler.
      }
      let addressLabel = self.addressLabel(context, address: immediate) ?? RGBDS.asHexString(immediate)
      if let condition = condition {
        return ["\(condition)", addressLabel]
      }

      return [addressLabel]

    // TODO: Consider removing this special case which assumes that all `ld hl imm16` instructions are loading globals.
    case let LR35902.Instruction.Spec.ld(operand1, operand2) where operand1 == .hl && operand2 == .imm16:
      guard case let .imm16(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }

      var addressLabel: String
      // TODO: These are only globals if they're referenced as an address in a subsequent instruction.
      if let argumentString = context.argumentString {
        addressLabel = argumentString
      } else if let name = context.disassembly.configuration.global(at: immediate)?.name {
        addressLabel = name
      } else {
        addressLabel = "$\(immediate.hexString)"
      }
      return [operand(for: instruction, operand: operand1, with: context), addressLabel]

    default:
      break
    }

    // Generic case.
    return operands(for: instruction, spec: instruction.spec, with: context)
  }

  /**
   Transforms an instruction's operands to their RGBDS assembly equivalent.

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
      return ["\(address)".replacingOccurrences(of: "x", with: RGBDS.NumericPrefix.hexadecimal)]

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

  /** Generic transformation of a single instruction operands to its RGBDS assembly equivalent. */
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

    case .ffimm8addr:
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      if let context = context {
        return "[\(prettify(imm16: 0xFF00 | UInt16(immediate), with: context))]"
      }
      return "[$FF\(immediate.hexString)]"

    case .imm8:
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }

      if let context = context, let typedValue = typedOperand(for: immediate, with: context) {
        return typedValue
      }

      return RGBDS.asHexString(immediate)

    case .simm8:
      guard case let .imm8(immediate) = instruction.immediate else {
        preconditionFailure("Invalid immediate associated with instruction")
      }
      if let context = context {
        let jumpAddress = (context.address + LR35902.InstructionSet.widths[instruction.spec]!.total).advanced(by: Int(Int8(bitPattern: immediate)))
        if context.disassembly.lastBankRouter?.transfersOfControl(at: Cartridge.Location(address: jumpAddress, bank: context.bank)) != nil {
          if let label = addressLabel(context, address: jumpAddress) {
            return label
          }
        }
      }

      let byte = immediate
      // Is the byte negative?
      if (byte & UInt8(0x80)) != 0 {
        return "@-" + RGBDS.asHexString(0xff - byte + 1 - 2)
      }

      // TODO: Document why we offset this byte by two.
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
        return "sp-" + RGBDS.asHexString(0xff - immediate + 1)
      }

      return "sp+" + RGBDS.asHexString(immediate)

    case .bcaddr:
      return "[bc]"

    case .zeroimm8:
      preconditionFailure("This operand is not meant to be represented in source")
    }
  }
}

// MARK: - Typed operands

extension RGBDSDisassembler {
  /** Returns an immediate 8 bit value represented as the inferred type at the context's execution location. */
  private static func typedOperand(for imm8: UInt8, with context: Context) -> String? {
    let location = Cartridge.Location(address: context.address, bank: context.bank)

    guard let type = context.disassembly.lastBankRouter?.type(at: location),
          let dataType = context.disassembly.configuration.datatype(named: type) else {
      if let instruction = context.disassembly.lastBankRouter?.instruction(at: location),
         instruction.spec == .and(.imm8) || instruction.spec == .xor(.imm8) || instruction.spec == .or(.imm8) {
        // Default to treating bit arithmetic as a binary type.
        return literal(for: imm8, using: .binary, with: context)
      }

      return nil  // No known data type.
    }

    switch dataType.interpretation {

    case .bitmask:
      // First, extract all of the bits that exactly match a named value.
      var namedValues: UInt8 = 0
      let bitmaskValues = dataType.namedValues.filter { value, _ in
        if value == 0 {
          // Only return this named value if the immediate is exactly 0, otherwise we would include it in every
          // expression.
          return imm8 == 0
        }
        if (imm8 & value) == value {
          namedValues = namedValues | value
          return true
        }
        return false
      }.values

      // Sort the named values for readability.
      var parts = bitmaskValues.sorted()

      // If there are any remaining bits in the mask, binary 'or' those as well.
      if namedValues != imm8 || parts.isEmpty {
        let remainingBits = imm8 & ~(namedValues)
        parts.append(literal(for: remainingBits, using: dataType.representation, with: context))
      }

      return parts.joined(separator: " | ")

    case .enumerated:
      let possibleValues = dataType.namedValues.filter { value, _ in value == imm8 }.values
      precondition(possibleValues.count <= 1, "Multiple possible values found.")
      if let value = possibleValues.first {
        return value
      }

    // If no enums matched, then fall-through.

    case .any:
      break  // Fall-through.
    }

    // Fall-through case represents the immediate as a literal numeric value.
    return literal(for: imm8, using: dataType.representation, with: context)
  }
}

// MARK: - Formatting literals

extension RGBDSDisassembler {
  /** Returns one of a label, a global, or a hexadecimal representation of a given imm16 value. */
  private static func prettify(imm16: UInt16, with context: Context) -> String {
    if let label = context.disassembly.lastBankRouter?.label(at: Cartridge.Location(address:imm16, bank: context.bank)) {
      return label
    }
    if let global = context.disassembly.configuration.global(at: imm16) {
      return global.name
    }
    return RGBDS.asHexString(imm16)
  }

  private static func addressLabel(_ context: Context, address immediate: (UInt16)) -> String? {
    // TODO: Why do we always assume that if there's an argument string that we should return it here?
    if let argumentString = context.argumentString {
      return argumentString
    }

    if let label = context.disassembly.lastBankRouter?.label(at: Cartridge.Location(address:immediate, bank: context.bank)) {
      if let scope = context.disassembly.lastBankRouter?.labeledContiguousScopes(at: Cartridge.Location(address: context.address, bank: context.bank))
          .first(where: { labeledScope in
            label.starts(with: "\(labeledScope).")
          }) {
        return label.replacingOccurrences(of: "\(scope).", with: ".")
      }

      return label
    }
    return nil
  }

  /** Returns the immediate formatted with the given representation. */
  private static func literal(for imm8: UInt8, using representation: Disassembler.Configuration.Datatype.Representation, with context: Context) -> String {
    let location = Cartridge.Location(address: context.address, bank: context.bank)
    let forcedRepresentation: Disassembler.Configuration.Datatype.Representation
    if let instruction = context.disassembly.lastBankRouter?.instruction(at: location),
       instruction.spec == .and(.imm8) || instruction.spec == .xor(.imm8) || instruction.spec == .or(.imm8) {
      // Always treat bit arithmetic as a bitmask, regardless of the type.
      forcedRepresentation = .binary
    } else {
      forcedRepresentation = representation
    }

    switch forcedRepresentation {
    case .binary:      return RGBDS.asBinaryString(imm8)
    case .decimal:     return RGBDS.asDecimalString(imm8)
    case .hexadecimal: return RGBDS.asHexString(imm8)
    }
  }
}
