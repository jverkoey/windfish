import Foundation

extension CPUInstructionSpec {
  /**
   Extracts the opcode from the name of the first part of the spec.
   */
  public var opcode: String {
    if let child = Mirror(reflecting: self).children.first {
      if let childInstruction = child.value as? Self {
        return childInstruction.opcode
      }
      return child.label!
    } else {
      return "\("\(self)".split(separator: ".").last!)"
    }
  }
}
