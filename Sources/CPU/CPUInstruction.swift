import Foundation

public protocol CPUInstruction: Hashable {
  associatedtype SpecType: CPUInstructionSpec

  var spec: SpecType { get }
}

public protocol CPUInstructionSpec: Hashable {
  associatedtype InstructionWidthType: BinaryInteger
  var opcode: String { get }
  
  var opcodeWidth: InstructionWidthType { get }
  var operandWidth: InstructionWidthType { get }

  var representation: String { get }
}
