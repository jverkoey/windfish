import Foundation

import FoundationExtensions

public let maxOpcodeNameLength = 4

/** A concrete representation of a single executable statement of RGBDS assembly. */
public struct Statement: Equatable {
  /** The statement's instruction code. */
  public let opcode: String

  /** The statement's operands, separated as one operand per element. */
  public let operands: [String]

  /** A concise, formatted RGBDS assembly string representation of this statement. */
  public let formattedString: String

  /** A tokenized representation of this statement that can be used for generalized lookups. */
  public let tokenizedString: String

  /** Initializes the statement with an opcode and operands. */
  public init(opcode: String, operands: [String] = []) {
    self.opcode = opcode
    self.operands = operands
    self.tokenizedString = Statement.createTokenizedString(opcode: opcode, operands: operands)
    self.formattedString = Statement.createString(opcode: opcode, operands: operands)
  }

  /** Initializes the statement as a data representation of the given bytes. */
  public init(representingBytes bytes: [UInt8]) {
    self.init(opcode: "db", operands: bytes.map { "$\($0.hexString)" })
  }

  /** Initializes the statement as a data representation using a named constant. */
  public init(representingBytesWithConstant constant: String) {
    self.init(opcode: "db", operands: [constant])
  }

  /** Extracts a statement from the given line, if a statement exists. */
  public init?(fromLine line: String) {
    let codeAndComments = line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
    let opcodeAndOperands = codeAndComments[0].trimmed().split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)

    let opcode = opcodeAndOperands[0].trimmed().lowercased()
    if opcode.count > 0 {
      self.opcode = opcode
    } else {
      return nil
    }

    if opcodeAndOperands.count > 1 {
      let quote = "\""
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
    self.tokenizedString = Statement.createTokenizedString(opcode: opcode, operands: operands)
    self.formattedString = Statement.createString(opcode: opcode, operands: operands)
  }
}

// MARK: - Internal methods

extension Statement {
  private static func createString(opcode: String, operands: [String]) -> String {
    if !operands.isEmpty {
      return "\(opcode.padding(toLength: maxOpcodeNameLength, withPad: " ", startingAt: 0)) \(operands.joined(separator: ", "))"
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
