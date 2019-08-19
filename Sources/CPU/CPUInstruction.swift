import Foundation

/**
 A generic instruction type backed by a specification.
 */
public protocol CPUInstruction: Hashable {
  associatedtype SpecType: CPUInstructionSpec

  var spec: SpecType { get }
}

/**
 An instruction specification defines the shape of the instruction.
 */
public protocol CPUInstructionSpec: Hashable {
  associatedtype WidthType: BinaryInteger

  /**
   The width of the instruction's opcode.
   */
  var opcodeWidth: WidthType { get }

  /**
   The width of the instruction's operands, if any.
   */
  var operandWidth: WidthType { get }

  /**
   The assembly opcode for this instruction.
   */
  var opcode: String { get }

  /**
   An abstract representation of this instruction in assembly.

   The following wildcards are permitted:

   - #: Any numeric value.
   */
  var representation: String { get }
}

public protocol CPUInstructionImmediate {
  /**
   The width of the immediate.
   */
  var width: Int { get }
}
