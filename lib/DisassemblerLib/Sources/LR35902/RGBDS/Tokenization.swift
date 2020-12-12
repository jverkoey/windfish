import Foundation

import RGBDS

extension LR35902.InstructionSet {
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
      try! spec.visit { operand in
        // Optional operands are provided by the visitor as boxed optional types represented as an Any.
        // We can't cast an Any to an Any? using the as? operator, so perform an explicit Optional-type unboxing instead:
        guard let valueUnboxed = operand?.value,
              case Optional<Any>.some(let value) = valueUnboxed else {
          return
        }

        if let representable = value as? InstructionOperandTokenizable {
          operands.append(representable.token.asString())
        } else {
          operands.append("\(value)")
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
