import Foundation

extension InstructionSpec {
  /**
   Returns a generic representation of the instruction by visiting each of the operands and returning their representable versions.
   */
  public var representation: String {
    var operands: [String] = []
    visit { (value, _) in
      // Optional operands are provided by the visitor as boxed optional types represented as an Any.
      // We can't cast an Any to an Any? using the as? operator, so perform an explicit Optional-type unboxing instead:
      guard let valueUnboxed = value,
        case Optional<Any>.some(let value) = valueUnboxed else {
        return
      }

      if let representable = value as? InstructionOperandAssemblyRepresentable {
        switch representable.representation {
        case .numeric:
          operands.append("#")
        case .address:
          operands.append("[#]")
        case .stackPointerOffset:
          operands.append("sp+#")
        case let .specific(string):
          operands.append(string)
        }
      } else {
        operands.append("\(value)")
      }
    }
    var representationParts = [opcode]
    if !operands.isEmpty {
      representationParts.append(operands.joined(separator: ", "))
    }
    return representationParts.joined(separator: " ")
  }
}
