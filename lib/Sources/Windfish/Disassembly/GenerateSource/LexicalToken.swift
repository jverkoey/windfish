import Foundation

/** A representation of a single lexical token in a line. */
public struct LexicalToken: Equatable {
  public enum LexicalUnit {
    case assemblyOperator
    case literal
    case label
  }
  public let lexicalUnit: LexicalUnit
  public let rangeInLine: Range<Int>

  init(lexicalUnit: LexicalToken.LexicalUnit, rangeInLine: Range<Int>) {
    self.lexicalUnit = lexicalUnit
    self.rangeInLine = rangeInLine
  }
}
