import Foundation

import FoundationExtensions

public let maxOpcodeNameLength = 4

/** A concrete representation of a single executable statement of RGBDS assembly. */
public final class Statement {
  // BEGIN ORDER MATTERS DUE TO MIRROR DESCENDANT ASSUMPTIONS
  /** The statement's instruction code. */
  public let opcode: String

  /** The statement's operands, separated as one operand per element. */
  public let operands: [String]
  // END ORDER MATTERS DUE TO MIRROR DESCENDANT ASSUMPTIONS

  /** A concise, formatted RGBDS assembly string representation of this statement. */
  public private(set) lazy var formattedString: String = {
    Statement.createFormattedString(opcode: opcode, formattedOpcode: formattedOpcode, operands: operands)
  }()

  /** The statement's instruction code padded for presentation. */
  public let formattedOpcode: String

  /** A tokenized representation of this statement that can be used for generalized lookups. */
  public private(set) lazy var tokenizedString: String = {
    Statement.createTokenizedString(opcode: opcode, operands: operands)
  }()

  /** Optional context that may be associated with this statement, typically an instruction specification.*/
  public var context: Any?

  /** Initializes the statement with an opcode and operands. */
  public init(opcode: String, operands: [String] = []) {
    self.opcode = opcode
    self.operands = operands
    let formattedOpcode: String
    if opcode.count < maxOpcodeNameLength {
      formattedOpcode = opcode.padding(toLength: maxOpcodeNameLength, withPad: " ", startingAt: 0)
    } else {
      formattedOpcode = opcode
    }
    self.formattedOpcode = formattedOpcode
    self.tokenizedString = Statement.createTokenizedString(opcode: opcode, operands: operands)
    self.formattedString = Statement.createFormattedString(opcode: opcode, formattedOpcode: formattedOpcode, operands: operands)
  }

  /** Initializes the statement as a data representation of the given bytes. */
  public convenience init(representingBytes bytes: [UInt8]) {
    self.init(opcode: "db", operands: bytes.map { "$\($0.hexString)" })
  }

  /** Initializes the statement as a data representation using a named constant. */
  public convenience init(representingBytesWithConstant constant: String) {
    self.init(opcode: "db", operands: [constant])
  }

  /** Extracts a statement from the given line, if a statement exists. */
  public init?(fromLine line: String) {
    let codeAndComments = line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
    let opcodeAndOperands = codeAndComments[0].trimmed().split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)

    let opcode = opcodeAndOperands[0].trimmed().lowercased()
    guard !opcode.isEmpty else {
      return nil
    }
    self.opcode = opcode
    let formattedOpcode: String
    if opcode.count < maxOpcodeNameLength {
      formattedOpcode = opcode.padding(toLength: maxOpcodeNameLength, withPad: " ", startingAt: 0)
    } else {
      formattedOpcode = opcode
    }
    self.formattedOpcode = formattedOpcode

    if opcodeAndOperands.count > 1 {
      let quote: String = "\""
      self.operands = opcodeAndOperands[1].components(separatedBy: ",").map {
        // Only strip non-quoted whitespace from the operand.
        $0.components(separatedBy: quote)
          .enumerated()
          .map { ($0 % 2 == 1) ? $1 : $1.filter { !$0.isWhitespace } }
          .joined(separator: quote)
      }
    } else {
      self.operands = []
    }
  }
}

extension Statement: Equatable {
  public static func == (lhs: Statement, rhs: Statement) -> Bool {
    return lhs.opcode == rhs.opcode && lhs.operands == rhs.operands
  }
}

// MARK: - Internal methods

extension Statement {
  private static func createFormattedString(opcode: String, formattedOpcode: String, operands: [String]) -> String {
    if !operands.isEmpty {
      return "\(formattedOpcode) \(operands.joined(separator: ", "))"
    }
    return opcode
  }

  private static func createTokenizedString(opcode: String, operands: [String]) -> String {
    if !operands.isEmpty {
      return "\(opcode) \(operands.map { InstructionOperandToken(string: $0).asString() }.joined(separator: ", "))"
    }
    return opcode
  }
}
