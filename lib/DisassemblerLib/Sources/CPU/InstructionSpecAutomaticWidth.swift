import Foundation

/**
 An instruction operand that has a width.
 */
public protocol InstructionOperandWithBinaryFootprint {
  /**
   The width of the immediate.
   */
  var width: Int { get }
}

public protocol InstructionSpecAutomaticWidth: InstructionSpec {}

extension InstructionSpecAutomaticWidth {
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
    visit { operand in
      if let numeric = operand?.value as? InstructionOperandWithBinaryFootprint {
        width += WidthType(numeric.width)
      }
    }
    return width
  }

  public var instructionWidth: WidthType {
    return opcodeWidth + operandWidth
  }
}
