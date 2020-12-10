import Foundation

/** A computed representation of an instruction's binary width. */
public struct InstructionWidth<T: BinaryInteger> {
  /** The width of the opcode. */
  public let opcode: T

  /** The width of the operand(s). */
  public let operand: T

  /** The total width of the instruction. */
  public var total: T {
    return opcode + operand
  }
}

/** A representation of an instruction set. */
public protocol InstructionSet {
  /** The instruction set's instruction specification type. */
  associatedtype SpecType: InstructionSpec

  /**
   The primary table of instructions.

   The array's index is meant to correspond to the binary opcode value of the instruction. When no instruction is
   available for a given index, provide an invalid instruction specification as filler.
   */
  static var table: [SpecType] { get }

  /** Additional tables for multi-byte instructions. */
  static var prefixTables: [[SpecType]] { get }

  /**
   A map of specifications to computed widths.

   This is typically implemented by returning the result of `computeAllWidths()`.
   */
  static var widths: [SpecType: InstructionWidth<SpecType.WidthType>] { get }
}

// MARK: - Helper methods for computing properties

extension InstructionSet {
  /**
   Returns all specifications in this instruction set.
   */
  public static func allSpecs() -> [SpecType] {
    return (table + prefixTables.reduce([], +))
  }

  /** Calculates the widths for every specification in this set. */
  public static func computeAllWidths() -> [SpecType: InstructionWidth<SpecType.WidthType>] {
    var widths: [SpecType: InstructionWidth<SpecType.WidthType>] = [:]
    (allSpecs()).forEach { spec in
      widths[spec] = InstructionWidth(opcode: spec.opcodeWidth, operand: spec.operandWidth)
    }
    return widths
  }
}
