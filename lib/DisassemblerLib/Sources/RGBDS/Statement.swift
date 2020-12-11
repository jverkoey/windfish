import Foundation

import FoundationExtensions

public let maxOpcodeNameLength = 4

/** A concrete representation of a single executable statement of RGBDS assembly. */
public struct Statement: Equatable, CustomStringConvertible {
  public let opcode: String
  public let operands: [String]
  public init(opcode: String, operands: [String] = []) {
    self.opcode = opcode
    self.operands = operands
  }

  public init?(fromLine line: String) {
    // TODO: Consider swapping this with a Scanner.
    let codeAndComments = line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
    let opcodeAndOperands = codeAndComments[0].trimmed().split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)

    let opcode = opcodeAndOperands[0].trimmed().lowercased()
    if opcode.count > 0 {
      self.opcode = opcode
    } else {
      return nil
    }

    if opcodeAndOperands.count > 1 {
      self.operands = opcodeAndOperands[1].components(separatedBy: ",").map { $0.trimmed() }
    } else {
      self.operands = []
    }
  }

  public var description: String {
    let opcodeName = opcode.padding(toLength: maxOpcodeNameLength, withPad: " ", startingAt: 0)
    if !operands.isEmpty {
      return "\(opcodeName) \(operands.joined(separator: ", "))"
    } else {
      return opcodeName
    }
  }
}
