import Foundation

/**
 A concrete representation of an instruction in a CPU's instruction set.

 A instruction provides a complete representation of a specific action that the CPU is able to take.

 Each Instruction has an associated specification (spec). The spec describes the abstract representation of the
 instruction and is primarily used for translating instructions between text and binary representations.
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
