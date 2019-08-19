import Foundation

public protocol CPUInstruction: Hashable {
  associatedtype SpecType: CPUInstructionSpec

  var spec: SpecType { get }
}

public protocol CPUInstructionSpec: Hashable {
  var opcode: String { get }
}
