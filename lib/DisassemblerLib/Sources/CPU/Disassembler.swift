import Foundation

extension InstructionSet {
  /**
   Disassembles a specification from binary data, if possible.

   If `data` does not contain enough bytes to represent a valid instruction, then nil is returned.
   */
  public static func spec(from data: Data) -> SpecType? {
    var iterator = data.makeIterator()
    return spec(from: &iterator, table: table)
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
    let spec = table[Int(byte)]
    if let prefixTable = Self.prefixTables[spec] {
      return self.spec(from: &iterator, table: prefixTable)
    }
    return spec
  }
}
