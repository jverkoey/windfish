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
      case nop
      case ld(Operand)
      case ld(Operand, Operand)
      case sub(Spec)

      typealias WidthType = UInt16
    }

    enum Operand: Hashable {
      case imm8
      case imm16
      case a
      case arg(Int)
    }
  }
}
