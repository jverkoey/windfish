import Foundation

/**
 An instruction specification defines the shape of the instruction.
 */
public protocol InstructionSpec: Hashable {
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
   The category this instruction's opcode falls under, if any.
   */
  var category: InstructionCategory? { get }

  func asData() -> Data?

  /**
   An abstract representation of this instruction in assembly.

   The following wildcards are permitted:

   - #: Any numeric value.
   */
  var representation: String { get }
}

/**
 An instruction operand that has a width.
 */
public protocol InstructionOperandWithBinaryFootprint {
  /**
   The width of the immediate.
   */
  var width: Int { get }
}

/**
 An abstract representation of an instruction's operand.
 */
public protocol InstructionOperandAssemblyRepresentable {
  /**
   The operand's abstract representation.
   */
  var representation: InstructionOperandAssemblyRepresentation { get }
}

/**
 Possible types of abstract representations for instruction operands.
 */
public enum InstructionOperandAssemblyRepresentation {
  /**
   A numeric representation.
   */
  case numeric

  /**
   An address representation.
   */
  case address

  /**
   An FF## address representation.
   */
  case ffaddress

  /**
   A stack pointer offset representation.
   */
  case stackPointerOffset

  /**
   A specific representation.
   */
  case specific(String)
}
