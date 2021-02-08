import Foundation

// MARK: Assembly

extension Instruction {
  /**
   Returns the data representation of an instruction.

   This default implementation uses the pre-computed opcode table and its assumptions.
   */
  public func asData() -> Data {
    var buffer = Data()
    buffer.append(contentsOf: InstructionSetType.opcodeBytes[spec]!)
    if let data = immediate?.asData() {
      buffer.append(data)
    }
    return buffer
  }
}

// MARK: Disassembly

extension Instruction {
  /**
   Disassembles a complete instruction from binary data, if possible.

   If `data` does not contain enough bytes to represent a valid instruction, then nil is returned.
   */
  public static func from(_ data: Data) -> Self? {
    var iterator: Data.Iterator = data.makeIterator()
    guard let spec: SpecType = spec(from: &iterator, table: InstructionSetType.table) else {
      return nil
    }
    guard let instructionWidth: InstructionWidth<SpecType.AddressType> = InstructionSetType.widths[spec] else {
      preconditionFailure("\(spec) is missing its width, implying a misconfiguration of the instruction set."
                          + " Verify that all specifications are computing and storing a corresponding width in the"
                          + " instruction set's width table.")
    }

    if instructionWidth.immediate > 0 {
      var operandBytes: [UInt8] = []
      for _ in 0..<Int(truncatingIfNeeded: instructionWidth.immediate) {
        guard let byte: UInt8 = iterator.next() else {
          return nil
        }
        operandBytes.append(byte)
      }
      return Self.init(spec: spec, immediate: Self.ImmediateType.init(data: Data(operandBytes)))
    }

    return Self.init(spec: spec, immediate: nil)
  }

  /**
   Disassembles a specification from binary data, if possible.

   If `data` does not contain enough bytes to represent a valid instruction opcode, then nil is returned.
   */
  public static func spec(from data: Data) -> SpecType? {
    var iterator = data.makeIterator()
    return spec(from: &iterator, table: InstructionSetType.table)
  }

  /**
   Recurses through instruction lookup tables until a valid spec is found.

   Each recursion advances the data iterator forward by one byte. The byte is used to look up the specification in the
   current instruction table.
   */
  private static func spec(from iterator: inout Data.Iterator, table: [SpecType]) -> SpecType? {
    guard let byte = iterator.next() else {
      return nil
    }
    let index = Int(truncatingIfNeeded: byte)
    guard index < table.count else {
      return nil
    }
    // TODO[https://github.com/jverkoey/windfish/issues/24]: Loop prefix tables to support 3+ byte opcodes.
    let spec = table[index]
    if let prefixTable = InstructionSetType.prefixTables[spec] {
      return self.spec(from: &iterator, table: prefixTable)
    }
    return spec
  }
}
