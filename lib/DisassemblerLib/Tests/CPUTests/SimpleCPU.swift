import Foundation
import CPU

/**
 A barebones implementation of a hypothetical CPU instruction set.

 This CPU implements the smallest possible set of protocols and implements all methods explicitly.
 */
struct SimpleCPU {
  /**
   A concrete representation of a single instruction for this CPU.
   */
  struct Instruction: CPU.Instruction {
    /**
     The instruction's specification.
     */
    let spec: Instruction.Spec

    enum ImmediateValue: Equatable {
      case imm8(UInt8)
      case imm16(UInt16)
    }
    let immediate: ImmediateValue?

    indirect enum Spec: Equatable {
      case nop
      case cp(Numeric)
      case ld(Numeric, Numeric)
      case sub(Spec)

      enum Numeric: Equatable {
        case imm8
        case imm16
        case a
        case arg(Int)
      }
    }
  }
}

extension SimpleCPU.Instruction.Spec: InstructionSpec {
  var opcodeWidth: UInt16 {
    switch self {
    case let .sub(spec):
      return 1 + spec.opcodeWidth
    default:
      return 1
    }
  }

  var operandWidth: UInt16 {
    switch self {
    case let .ld(operand1, operand2):
      return operand1.width + operand2.width
    case let .cp(operand):
      return operand.width
    case let .sub(spec):
      return spec.operandWidth
    default:
      return 0
    }
  }
}

extension SimpleCPU.Instruction.Spec.Numeric {
  var width: UInt16 {
    switch self {
    case .imm8:
      return 1
    case .imm16:
      return 2
    default:
      return 0
    }
  }
}