import Foundation

/**
 A concrete representation of a single instruction in a CPU's instruction set.

 A instruction provides a complete representation of a specific operation that the CPU is able to perform.

 Each Instruction has an associated specification (spec). The spec defines the shape and size of the Instruction, but
 not the conrete values contained within; the Instruction is expected to store the concrete information such as an
 immediate (imm) value or a memory address.
 */
public protocol Instruction: Hashable {
  /**
   The type of the specification that is associated with this instruction.

   This type is typically an enum consisting of one case per abstract instruction.
   */
  associatedtype SpecType: InstructionSpec

  /**
   The instruction's specification.

   The returned specification is assumed to be a representation of the concrete instruction.
   */
  var spec: SpecType { get }
}

/**
 A representation of the shape of instructions found in a CPU's instruction set.

 Implementing this protocol makes it possible to calculate the size of a given instruction.

 This protocol is typically implemented as an enum type in which each case defines the shape of a single instruction.
 If the instruction set has prefix instructions (e.g. two-byte instructions in an otherwise single-byte instruction set)
 then the enum can be declared `indirect` in order to support recursion.
 */
public protocol InstructionSpec: Hashable {
  /**
   The type to be used for all width expressions.

   The chosen type should support the largest addressable value for the CPU. For example, a 32 bit CPU would use a width
   type of UInt32, while a 16 bit CPU would use UInt16.
   */
  associatedtype WidthType: BinaryInteger

  /**
   The byte width of the instruction's opcode.
   */
  var opcodeWidth: WidthType { get }

  /**
   The byte width of the instruction's operands, if any.
   */
  var operandWidth: WidthType { get }
}
