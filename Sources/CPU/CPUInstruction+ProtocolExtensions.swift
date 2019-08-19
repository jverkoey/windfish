import Foundation

extension CPUInstructionSpec {
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
