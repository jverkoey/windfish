import Foundation

/** A computed representation of an instruction's binary width. */
public struct InstructionWidth<T: BinaryInteger>: Equatable {
  public init(opcode: T, operand: T) {
    self.opcode = opcode
    self.operand = operand
  }

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
  /** The instruction type this set consists of. */
  associatedtype InstructionType: Instruction
  typealias SpecType = InstructionType.SpecType
  typealias InstructionTable = [SpecType]

  /**
   The primary table of instructions.

   The array's index is meant to correspond to the binary opcode value of the instruction. When no instruction is
   available for a given index, provide an invalid instruction specification as filler.
   */
  static var table: InstructionTable { get }

  /** Additional tables for multi-byte instructions. */
  static var prefixTables: [SpecType: InstructionTable] { get }

  /**
   A cached map of specifications to computed widths.

   This is typically implemented by returning the result of `computeAllWidths()`.
   */
  static var widths: [SpecType: InstructionWidth<SpecType.WidthType>] { get }

  /**
   A cached map of specifications to their binary opcode representations.

   This is typically implemented by returning the result of `computeAllOpcodeBytes()`.
   */
  static var opcodeBytes: [SpecType: [UInt8]] { get }

  /** Converts the specification to a binary representation. */
  static func data(for spec: SpecType) -> Data?
}

// MARK: - Automatic data representation

extension InstructionSet {
  public static func data(for spec: SpecType) -> Data? {
    guard let bytes = opcodeBytes[spec] else {
      return nil
    }
    return Data(bytes)
  }
}

// MARK: - Helper methods for computing properties

extension InstructionSet {
  /** Returns all specifications in this instruction set. */
  public static func allSpecs() -> [SpecType] {
    return (table + prefixTables.values.reduce([], +))
  }

  /** Calculates the widths for every specification in this set. */
  public static func computeAllWidths() -> [SpecType: InstructionWidth<SpecType.WidthType>] {
    var widths: [SpecType: InstructionWidth<SpecType.WidthType>] = [:]
    allSpecs().forEach { spec in
      widths[spec] = InstructionWidth(opcode: spec.opcodeWidth, operand: spec.operandWidth)
    }
    return widths
  }

  /**
   Calculates the opcode for every instruction in this set.

   Assumes that each instruction specification's opcode byte corresponds to its index in its corresponding instruction
   table.
   */
  public static func computeAllOpcodeBytes() -> [SpecType: [UInt8]] {
    var binary: [SpecType: [UInt8]] = [:]
    computeAllOpcodeBytes(accumulator: &binary, table: table, prefix: [])
    return binary
  }
}

// MARK: - Internal methods

extension InstructionSet {
  /** Recursively computes opcodes by traversing tables when prefixes are encountered. */
  private static func computeAllOpcodeBytes(accumulator: inout [SpecType: [UInt8]],
                                            table: [SpecType],
                                            prefix: [UInt8]) {
    for (byteRepresentation, spec) in table.enumerated() {
      let opcode = prefix + [UInt8(byteRepresentation)]
      if let prefixTable = prefixTables[spec] {
        computeAllOpcodeBytes(accumulator: &accumulator,
                              table: prefixTable,
                              prefix: opcode)
      } else {
        accumulator[spec] = opcode
      }
    }
  }
}
