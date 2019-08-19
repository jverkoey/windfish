import Foundation

public struct CPUInstructionWidth<T: BinaryInteger> {
  public let opcode: T
  public let operand: T

  public var total: T {
    return opcode + operand
  }
}

/**
 Calculates the widths for all of the given instructions.
 */
public func widths<T: CPUInstructionSpec>(for instructionSet: [T]) -> [T: CPUInstructionWidth<T.InstructionWidthType>] {
  var widths: [T: CPUInstructionWidth<T.InstructionWidthType>] = [:]
  instructionSet.forEach { spec in
    widths[spec] = CPUInstructionWidth(opcode: spec.opcodeWidth, operand: spec.operandWidth)
  }
  return widths
}

extension CPUInstructionSpec {
  /**
   Extracts the opcode width by adding up recursive specifications.
   */
  public var opcodeWidth: InstructionWidthType {
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

  public var instructionWidth: InstructionWidthType {
    return opcodeWidth + operandWidth
  }
}
