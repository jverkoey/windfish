import Foundation

public protocol CPUInstruction: Hashable {
  associatedtype SpecType: CPUInstructionSpec

  var spec: SpecType { get }
}

public protocol CPUInstructionSpec: Hashable {
  var opcode: String { get }
}

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
