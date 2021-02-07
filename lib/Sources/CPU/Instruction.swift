import Foundation

/**
 A concrete representation of a single instruction in a CPU's instruction set.

 A instruction provides a complete representation of a specific operation that the CPU is able to perform.

 Each Instruction has an associated specification (spec). The spec defines the shape and size of the Instruction, but
 not the conrete values contained within; the Instruction is expected to store the concrete information such as an
 immediate (imm) value or a memory address.
 */
public protocol Instruction {
  /**
   The type of the specification that is associated with this instruction.

   This type is typically an enum consisting of one case per abstract instruction.
   */
  associatedtype SpecType: InstructionSpec

  /**
   The type of the immediate that is associated with this instruction.

   This type is typically an associated enum where each case supports a specific immediate size.
   */
  associatedtype ImmediateType: InstructionImmediate

  /**
   The instruction's specification.

   The specification should describe this instruction.
   */
  var spec: SpecType { get }

  /** The instruction's immediate, if one exists. */
  var immediate: ImmediateType? { get }

  /** Initializes the instruction with a given specification and optional immediate value. */
  init(spec: SpecType, immediate: ImmediateType?)
}

/**
 A representation of the shape of instructions found in a CPU's instruction set.

 Implementing this protocol makes it possible to calculate the size of a given instruction.

 This protocol is typically implemented as an enum type in which each case defines the shape of a single instruction.
 If the instruction set has prefix instructions (e.g. two-byte instructions in an otherwise single-byte instruction set)
 then the enum can be declared `indirect` in order to support recursion.

 This type conforms to Hashable because instruction specifications are often used as keys in lookup tables.
 */
public protocol InstructionSpec: Hashable {
  /**
   The type to be used for all address expressions.

   The chosen type should support the largest addressable value for the CPU. For example, a 32 bit CPU would use a width
   type of UInt32, while a 16 bit CPU would use UInt16.
   */
  associatedtype AddressType: BinaryInteger

  /** The byte width of the instruction's opcode. */
  var opcodeWidth: AddressType { get }

  /** The byte width of the instruction's operands, if any. */
  var operandWidth: AddressType { get }
}

/**
 A representation of an instruction's immediate value.

 An immediate is one or more bytes of information associated with the instruction.
 */
public protocol InstructionImmediate: Hashable {
  /** Initializes the immediate from a specific set of bytes, if possible. */
  init?(data: Data)

  /** Converts the immediate to a data representation of itself. */
  func asData() -> Data
}

// MARK: - Automatic width computation

/** An instruction operand that has a width. */
public protocol InstructionOperandWithBinaryFootprint {
  /** The width of the immediate. */
  var width: Int { get }
}

extension InstructionSpec {
  /** Extracts the opcode width by adding up specifications recursively. */
  public var opcodeWidth: AddressType {
    let sizeOfInstruction: AddressType = 1  // TODO: Evaluate whether this should be configurable.
    guard let operands = Mirror(reflecting: self).children.first else {
      return sizeOfInstruction
    }
    switch operands.value {
    case let childInstruction as Self:
      return sizeOfInstruction + childInstruction.opcodeWidth
    default:
      return sizeOfInstruction
    }
  }

  /** Computes the operand width by adding up the width of any immediate operands. */
  public var operandWidth: AddressType {
    var width: AddressType = 0
    try? visit { operand, _ in
      if let numeric = operand?.value as? InstructionOperandWithBinaryFootprint {
        width += AddressType(numeric.width)
      }
    }
    return width
  }
}
