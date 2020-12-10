import Foundation

extension InstructionSet {
  /**
   Disassembles a specification from binary data, if possible.

   If `data` does not contain enough bytes to represent a valid instruction opcode, then nil is returned.
   */
  public static func spec(from data: Data) -> SpecType? {
    var iterator = data.makeIterator()
    return spec(from: &iterator, table: table)
  }

  /**
   Disassembles a complete instruction from binary data, if possible.

   If `data` does not contain enough bytes to represent a valid instruction, then nil is returned.
   */
  public static func instruction(from data: Data) -> InstructionType? {
    var iterator = data.makeIterator()
    guard let spec = spec(from: &iterator, table: table) else {
      return nil
    }
    guard let instructionWidth = widths[spec] else {
      preconditionFailure("\(spec) is missing its width, implying a misconfiguration of the instruction set."
                          + " Verify that all specifications are computing and storing a corresponding width in the"
                          + " instruction set's width table.")
    }

    if instructionWidth.operand > 0 {
      var operandBytes: [UInt8] = []
      for _ in 0..<Int(instructionWidth.operand) {
        guard let byte = iterator.next() else {
          return nil
        }
        operandBytes.append(byte)
      }
      return InstructionType.init(spec: spec, immediate: InstructionType.ImmediateType.init(data: Data(operandBytes)))
    }

    return InstructionType.init(spec: spec, immediate: nil)
  }
}

extension InstructionSet {
  /**
   Recurses through instruction lookup tables until a valid spec is found.

   Each recursion advances the data iterator forward by one byte. The byte is used to look up the specification in the
   current instruction table.
   */
  private static func spec(from iterator: inout Data.Iterator, table: [SpecType]) -> SpecType? {
    guard let byte = iterator.next() else {
      return nil
    }
    let index = Int(byte)
    guard index < table.count else {
      return nil
    }
    let spec = table[index]
    if let prefixTable = Self.prefixTables[spec] {
      return self.spec(from: &iterator, table: prefixTable)
    }
    return spec
  }
}
