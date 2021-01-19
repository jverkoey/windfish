import Foundation

import CPU
import FoundationExtensions
import RGBDS

/**
 Turns RGBDS assembly code into LR35902 instructions.

 This is a simplified parser for RGBDS syntax. It does not support all RGBDS features because the only purpose of this
 assembler is to support Windfish's macroing system, which only requires the ability to describe a list of instructions.
 Mathematical expressions and other additional features of that kind are intentionally not implemented.
 */
final class RGBDSAssembler {

  /** Error thrown when assembly fails for an RGBDS statement. */
  struct StringError: Swift.Error, Equatable {
    /** A description of the error that occurred. */
    public let message: String
  }

  /**
   Attempts to create an instruction with the given specification from the given statement.

   If the specification has any numeric operand, then the operand's value will be extracted from the statement. If the
   operand value does not match the specification's value or width, then no instruction will be returned.

   It is assumed that the specifications loosely match the statement's tokenizedString representation.
   */
  static func instruction(from statement: RGBDS.Statement, using spec: LR35902.Instruction.Spec) throws -> LR35902.Instruction? {
    if case LR35902.Instruction.Spec.stop = spec {
      // stop is always followed by a zero byte, so we special case it here.
      precondition(statement.opcode == "stop")
      return LR35902.Instruction(spec: spec, immediate: .imm8(0))
    }
    // Assume that the instruction is fine as-is, but allow it to be nil'd out if validation does not pass.
    var instruction: LR35902.Instruction? = LR35902.Instruction(spec: spec)

    // Visit each operand, validating and extracting the statement's corresponding operand value when needed.
    try spec.visit { operand, shouldStop in
      guard let operand: (value: Any, index: Int) = operand else {
        // Base case of no operands.
        shouldStop = true
        return
      }
      let value: String = statement.operands[operand.index]
      switch operand.value {

      case let restartAddress as LR35902.Instruction.RestartAddress:
        guard let numericValue: UInt16 = RGBDS.integer(from: value) else {
          throw StringError(message: "Unable to represent \(value) as a \(UInt16.self)")
        }
        guard numericValue == restartAddress.rawValue else {
          instruction = nil
          shouldStop = true
          break
        }

      case let bit as LR35902.Instruction.Bit:
        guard let numericValue: UInt8 = RGBDS.integer(from: value) else {
          throw StringError(message: "Unable to represent \(value) as a \(UInt8.self)")
        }
        guard numericValue == bit.rawValue else {
          instruction = nil
          shouldStop = true
          break
        }

      case LR35902.Instruction.Numeric.imm16:
        guard let numericValue: UInt16 = RGBDS.integer(from: value) else {
          throw StringError(message: "Unable to represent \(value) as a \(UInt16.self)")
        }
        instruction = LR35902.Instruction(spec: spec, immediate: .imm16(numericValue))

      case LR35902.Instruction.Numeric.imm8, LR35902.Instruction.Numeric.simm8:
        let isRelativeToPc: Bool = value.hasPrefix(RGBDS.Symbol.pc)

        var strippedValue: String
        if isRelativeToPc {
          strippedValue = String(value.dropFirst())
        } else {
          strippedValue = value
        }
        if strippedValue.hasPrefix("+") {
          strippedValue = String(strippedValue.dropFirst())
        }
        guard var numericValue: UInt8 = RGBDS.integer(from: strippedValue) else {
          throw StringError(message: "Unable to represent \(value) as a \(UInt8.self)")
        }
        if isRelativeToPc {
          // Relative jumps in assembly are written from the point of view of the instruction's beginning.
          numericValue = numericValue &- UInt8(LR35902.InstructionSet.widths[spec]!.total)
        }
        instruction = LR35902.Instruction(spec: spec, immediate: .imm8(numericValue))

      case LR35902.Instruction.Numeric.ffimm8addr:
        guard let numericValue: UInt16 = RGBDS.integer(fromAddress: value) else {
          throw StringError(message: "Unable to represent \(value) as a \(UInt16.self)")
        }
        guard (numericValue & 0xFF00) == 0xFF00 else {
          // Address didn't pass validation.
          instruction = nil
          shouldStop = true
          break
        }
        let lowerByteValue = UInt8(truncatingIfNeeded: numericValue)
        instruction = LR35902.Instruction(spec: spec, immediate: .imm8(lowerByteValue))

      case LR35902.Instruction.Numeric.sp_plus_simm8:
        guard let numericValue: UInt8 = RGBDS.integer(fromStackPointer: value) else {
          throw StringError(message: "Unable to represent \(value) as a \(UInt8.self)")
        }
        instruction = LR35902.Instruction(spec: spec, immediate: .imm8(numericValue))

      case LR35902.Instruction.Numeric.imm16addr:
        guard let numericValue: UInt16 = RGBDS.integer(fromAddress: value) else {
          throw StringError(message: "Unable to represent \(value) as a \(UInt16.self)")
        }
        instruction = LR35902.Instruction(spec: spec, immediate: .imm16(numericValue))
      default:
        break
      }
    }
    return instruction
  }
}
