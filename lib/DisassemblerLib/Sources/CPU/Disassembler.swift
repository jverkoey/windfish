import Foundation

private class IteratorWrapper {
  internal init(iterator: Data.Iterator) {
    self.iterator = iterator
  }

  var iterator: Data.Iterator

  func next() -> UInt8? {
    return iterator.next()
  }
}

extension InstructionSet {
  public static func spec(from data: Data) -> SpecType? {
    let iterator = IteratorWrapper(iterator: data.makeIterator())
    return spec(from: iterator, table: table)
  }

  private static func spec(from iterator: IteratorWrapper, table: [SpecType]) -> SpecType? {
    guard let byte = iterator.next() else {
      return nil
    }
    let spec = table[Int(byte)]
    if let prefixTable = Self.prefixTables[spec] {
      return self.spec(from: iterator, table: prefixTable)
    }
    return spec
  }
}

