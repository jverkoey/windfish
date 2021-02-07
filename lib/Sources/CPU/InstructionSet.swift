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
  static var widths: [SpecType: InstructionWidth<SpecType.AddressType>] { get }

  /**
   A cached map of specifications to their opcode binary representations.

   This is typically implemented by returning the result of `computeAllOpcodeBytes()`.
   */
  static var opcodeBytes: [SpecType: [UInt8]] { get }

  /**
   A cached map of specifications to their opcode string representations.

   This is typically implemented by returning the result of `computeAllOpcodeStrings()`.
   */
  static var opcodeStrings: [SpecType: String] { get }

  /**
   A cached map of specifications to their reflected argument representations.

   This is typically implemented by returning the result of `computeAllReflectedArgumentTypes()`.
   */
  static var reflectedArgumentTypes: [SpecType: Any] { get }

  /** Returns the data representation of an instruction. */
  static func data(representing instruction: InstructionType) -> Data
}

// MARK: - Default implementations

extension InstructionSet {
  /**
   Returns the data representation of an instruction.

   This default implementation uses the pre-computed opcode table and its assumptions.
   */
  public static func data(representing instruction: InstructionType) -> Data {
    var buffer = Data()
    buffer.append(contentsOf: opcodeBytes[instruction.spec]!)
    if let data = instruction.immediate?.asData() {
      buffer.append(data)
    }
    return buffer
  }
}

// MARK: - Helper methods for computing properties

extension InstructionSet {
  /** Returns all specifications in this instruction set. */
  public static func allSpecs() -> [SpecType] {
    return (table + prefixTables.values.reduce([], +))
  }

  /** Calculates the widths for every specification in this set. */
  public static func computeAllWidths() -> [SpecType: InstructionWidth<SpecType.AddressType>] {
    var widths: [SpecType: InstructionWidth<SpecType.AddressType>] = [:]
    allSpecs().forEach { spec in
      widths[spec] = InstructionWidth(opcode: spec.opcodeWidth, operand: spec.operandWidth)
    }
    return widths
  }

  /**
   Calculates the opcode bytes for every instruction specification in this set.

   Assumes that each instruction specification's opcode byte corresponds to its index in its corresponding instruction
   table.
   */
  public static func computeAllOpcodeBytes() -> [SpecType: [UInt8]] {
    var binary: [SpecType: [UInt8]] = [:]
    computeOpcodeBytes(for: table, prefix: [], accumulator: &binary)
    return binary
  }

  /**
   Calculates the opcode string for every instruction specification in this set.

   Assumes that the name of the enum case in the specification's enum definition is exactly the opcode's string
   representation.
   */
  public static func computeAllOpcodeStrings() -> [SpecType: String] {
    return allSpecs().reduce(into: [:]) { accumulator, spec in
      accumulator[spec] = computeOpcodeString(for: spec)
    }
  }

  /** Creates the mirror for every instruction specification in this set. */
  public static func computeAllReflectedArgumentTypes() -> [SpecType: Any] {
    return allSpecs().reduce(into: [:]) { accumulator, spec in
      let mirror: Mirror = Mirror(reflecting: spec)
      if let subSpec: SpecType = mirror.children.first?.value as? SpecType {
        accumulator[spec] = Mirror(reflecting: subSpec).children.first?.value
      } else {
        accumulator[spec] = mirror.children.first?.value
      }
    }
  }
}

// MARK: - Internal methods

extension InstructionSet {
  /** Recursively computes an opcode's bytes by traversing tables when prefixes are encountered. */
  private static func computeOpcodeBytes(for table: [SpecType],
                                         prefix: [UInt8],
                                         accumulator: inout [SpecType: [UInt8]]) {
    for (byteRepresentation, spec) in table.enumerated() {
      let opcode = prefix + [UInt8(byteRepresentation)]
      if let prefixTable = prefixTables[spec] {
        computeOpcodeBytes(for: prefixTable, prefix: opcode, accumulator: &accumulator)
      } else {
        accumulator[spec] = opcode
      }
    }
  }

  /** Recursively computes an opcode's string by traversing tables when prefixes are encountered. */
  private static func computeOpcodeString(for spec: SpecType) -> String? {
    // Prefix table specifications don't have a corresponding opcode.
    if prefixTables[spec] != nil {
      return nil
    }
    if let child = Mirror(reflecting: spec).children.first {
      if let childInstruction = child.value as? SpecType {
        return computeOpcodeString(for: childInstruction)
      }
      return child.label!
    }
    return "\("\(spec)".split(separator: ".").last!)"
  }
}
