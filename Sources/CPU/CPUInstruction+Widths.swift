import Foundation

/**
 Calculates the widths for all of the given instructions.
 */
public func widths<T: CPUInstructionSpec>(for instructionSet: [T]) -> [T: T.InstructionWidthType] {
  var widths: [T: T.InstructionWidthType] = [:]
  instructionSet.forEach { spec in
    widths[spec] = spec.opcodeWidth + spec.operandWidth
  }
  return widths
}
