import Foundation

extension CPUInstructionSpec {
  /**
   Returns a generic representation of the instruction by visiting each of the operands and returning their representable versions.
   */
  public var representation: String {
    var operands: [String] = []
    visit { (value, _) in
      guard let value = value else {
        return
      }

      // Optional operands are provided by the visitor as boxed optional types represented as an Any.
      // We can't cast an Any to an Any? using the as? operator, so perform an explicit Optional-type unboxing instead:
      var unboxedValue: Any
      if case Optional<Any>.some(let unboxed) = value {
        unboxedValue = unboxed
      } else {
        unboxedValue = value
      }

      if let representable = unboxedValue as? CPUInstructionOperandRepresentable {
        switch representable.representation {
        case .numeric:
          operands.append("#")
        case .address:
          operands.append("[#]")
        case let .specific(string):
          operands.append(string)
        }
      } else {
        operands.append("\(unboxedValue)")
      }
    }
    var representationParts = [opcode]
    if !operands.isEmpty {
      representationParts.append(operands.joined(separator: ", "))
    }
    return representationParts.joined(separator: " ")
  }
}
