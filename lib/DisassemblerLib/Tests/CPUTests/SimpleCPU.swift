//
//  File.swift
//  
//
//  Created by Jeff Verkoeyen on 12/9/20.
//

import Foundation
import CPU

struct SimpleCPU {
  struct Instruction: CPU.Instruction {
    var spec: Instruction.Spec

    indirect enum Spec: InstructionSpec, Hashable {
      var opcodeWidth: UInt16 {
        return 1
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

      case nop
      case cp(Numeric)
      case ld(Numeric, Numeric)
      case sub(Spec)

      typealias WidthType = UInt16
    }

    enum Numeric: Hashable {
      case imm8
      case imm16
      case a
      case arg(Int)

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
  }
}
