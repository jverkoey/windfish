import Foundation

/**
 An abstract representation of the instructions in a CPU's instruction set.

 This protocol is expected to be implemented using an enum type where each case defines the shape of a single
 instruction.

 Implementing this protocol makes it possible to calculate the binary size of a given instruction.
 */
public protocol InstructionSpec: Hashable {
  /**
   The type to be used for all width expressions.

   The chosen type should support the largest addressable value for the CPU. For example, a 32 bit CPU would use a width
   type of UInt32, while a 16 bit CPU would use UInt16.
   */
  associatedtype WidthType: BinaryInteger

  /**
   The width of the instruction's opcode.
   */
  var opcodeWidth: WidthType { get }

  /**
   The width of the instruction's operands, if any.
   */
  var operandWidth: WidthType { get }
}
