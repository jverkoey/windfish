import Foundation

import RGBDS

extension LR35902.Instruction.Numeric: InstructionOperandTokenizable {
  public var token: InstructionOperandToken {
    switch self {
    case .bcaddr:
      return .specific("[bc]")
    case .deaddr:
      return .specific("[de]")
    case .hladdr:
      return .specific("[hl]")
    case .imm16addr:
      return .address
    case .ffimm8addr:
      return .ffaddress
    case .sp_plus_simm8:
      return .stackPointerOffset
    case .imm8, .simm8, .imm16:
      return .numeric
    default:
      return .specific("\(self)")
    }
  }
}

extension LR35902.Instruction.RestartAddress: InstructionOperandTokenizable {
  public var token: InstructionOperandToken {
    return .numeric
  }
}

extension LR35902.Instruction.Bit: InstructionOperandTokenizable {
  public var token: InstructionOperandToken {
    return .numeric
  }
}

extension LR35902.InstructionSet {
  /** Returns all possible specifications for the given statement. */
  public static func specs(for statement: RGBDS.Statement) -> [LR35902.Instruction.Spec] {
    let representation = statement.tokenizedString
    guard let specs = tokenStringToSpecs[representation] else {
      return []
    }
    return specs
  }

  /**
   A cached map of specifications to their tokenized representation.

   This is typically implemented by returning the result of `computeAllOpcodeStrings()`.
   */
  static var specToTokenString: [SpecType: String] = {
    return computeAllTokenStrings()
  }()

  /**
   A cached map of specifications to their tokenized representation.

   This is typically implemented by returning the result of `computeAllOpcodeStrings()`.
   */
  static var tokenStringToSpecs: [String: [SpecType]] = {
    return .init(specToTokenString.map { ($0.value, [$0.key]) }, uniquingKeysWith: +)
  }()

  private static func computeAllTokenStrings() -> [SpecType: String] {
    return allSpecs().reduce(into: [:]) { accumulator, spec in
      var operands: [String] = []
      try! spec.visit { operand, _ in
        guard let operand = operand else {
          return
        }
        if let representable = operand.value as? InstructionOperandTokenizable {
          operands.append(representable.token.asString())
        } else {
          operands.append("\(operand.value)")
        }
      }
      guard let opcode = opcodeStrings[spec] else {
        return
      }
      var representationParts = [opcode]
      if !operands.isEmpty {
        representationParts.append(operands.joined(separator: ", "))
      }
      accumulator[spec] = representationParts.joined(separator: " ")
    }
  }
}
