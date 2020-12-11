import Foundation

public let maxOpcodeNameLength = 4

/** A concrete representation of a single statement of RGBDS assembly. */
public struct Statement: Equatable, CustomStringConvertible {
  public let opcode: String
  public let operands: [String]?
  public let comments: String?
  public init(opcode: String, operands: [String]? = nil, comments: String? = nil) {
    self.opcode = opcode
    self.operands = operands
    self.comments = comments
  }

  public var description: String {
    let opcodeName = opcode.padding(toLength: maxOpcodeNameLength, withPad: " ", startingAt: 0)
    if let operands = operands {
      return "\(opcodeName) \(operands.joined(separator: ", "))"
    } else {
      return opcodeName
    }
  }
}
