import Foundation

// TODO: Make this automatic implementation something that can be opted in to because it's less performant.

/**
 A representation of an instruction's width.
 */
public struct InstructionWidth<T: BinaryInteger> {
  public let opcode: T
  public let operand: T

  public var total: T {
    return opcode + operand
  }
}

/**
 Calculates the widths for all of the given instructions.
 */
public func widths<T>(for instructionSet: [T]) -> [T: InstructionWidth<T.WidthType>] where T: InstructionSpec {
  var widths: [T: InstructionWidth<T.WidthType>] = [:]
  instructionSet.forEach { spec in
    widths[spec] = InstructionWidth(opcode: spec.opcodeWidth, operand: spec.operandWidth)
  }
  return widths
}

/**
 An instruction operand that has a width.
 */
public protocol InstructionOperandWithBinaryFootprint {
  /**
   The width of the immediate.
   */
  var width: Int { get }
}

public protocol InstructionSpecAutoWidthDetermination: InstructionSpec {
}

extension InstructionSpecAutoWidthDetermination {
  /**
   Extracts the opcode width by adding up recursive specifications.
   */
  public var opcodeWidth: WidthType {
    guard let operands = Mirror(reflecting: self).children.first else {
      return 1
    }
    switch operands.value {
    case let childInstruction as Self:
      return 1 + childInstruction.opcodeWidth
    default:
      return 1
    }
  }

  /**
   Computes the operand width by adding up the width of any immediate operands.
   */
  public var operandWidth: WidthType {
    var width: WidthType = 0
    visit { (value, _) in
      if let numeric = value as? InstructionOperandWithBinaryFootprint {
        width += WidthType(numeric.width)
      }
    }
    return width
  }

  public var instructionWidth: WidthType {
    return opcodeWidth + operandWidth
  }
}
