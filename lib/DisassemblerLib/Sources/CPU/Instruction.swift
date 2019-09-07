import Foundation

/**
 A generic instruction type backed by a specification.
 */
public protocol Instruction: Hashable {
  associatedtype SpecType: InstructionSpec

  var spec: SpecType { get }

  func operandData() -> Data?
}
