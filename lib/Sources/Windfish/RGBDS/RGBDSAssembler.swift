import Foundation

import CPU
import FoundationExtensions
import RGBDS

/** Turns RGBDS assembly code into LR35902 instructions. */
final class RGBDSAssembler {

  /** An error that occurred during parsing of RGBDS assembly. */
  struct Error: Swift.Error, Equatable {
    let lineNumber: Int
    let message: String
  }

  /**
   Assembles the assembly code into an intermediary format.

   If any portion of the assembly fails, then errors will also be returned.
   */
  static func assemble(assembly: String) -> (instructions: [LR35902.Instruction], errors: [Error]) {
    var lineNumber = 1
    var instructions: [LR35902.Instruction] = []
    var errors: [Error] = []

    assembly.enumerateLines { (line, stop) in
      defer {
        lineNumber += 1
      }

      do {
        guard let instruction = try instruction(from: line) else {
          return
        }
        instructions.append(instruction)

      } catch let error as StringError {
        errors.append(.init(lineNumber: lineNumber, message: error.message))
      } catch let error as RGBDSAssembler.Error {
        errors.append(error)
      } catch {
        errors.append(.init(lineNumber: lineNumber, message: "Unknown error"))
      }
    }
    return (instructions: instructions, errors: errors)
  }

  /** Creates an instruction from the given line, if the line contains a parsable instruction statement. */
  private static func instruction(from line: String) throws -> LR35902.Instruction? {
    guard let statement = RGBDS.Statement(fromLine: line) else {
      return nil
    }
    let specs = LR35902.InstructionSet.specs(for: statement)
    if specs.isEmpty {
      throw StringError(message: "No valid instruction found for \(statement.formattedString)")
    }
    let potentialInstructions: [LR35902.Instruction] = try specs.compactMap { spec in
      try RGBDSAssembler.instruction(from: statement, using: spec)
    }
    guard potentialInstructions.count > 0 else {
      throw StringError(message: "No instruction was able to represent \(statement.formattedString)")
    }
    let shortestInstruction = potentialInstructions.sorted(by: { pair1, pair2 in
      LR35902.InstructionSet.widths[pair1.spec]!.total < LR35902.InstructionSet.widths[pair2.spec]!.total
    })[0]
    return shortestInstruction
  }

  /**
   Attempts to create an instruction with the given specification from the given statement.

   If the specification has any numeric operand, then the operand's value will be extracted from the statement. If the
   operand value does not match the specification's value or width, then no instruction will be returned.

   It is assumed that the specifications loosely match the statement's tokenizedString representation.
   */
  static func instruction(from statement: RGBDS.Statement, using spec: LR35902.Instruction.Spec) throws -> LR35902.Instruction? {
    if case LR35902.Instruction.Spec.stop = spec {
      // stop is always followed by a zero byte
      return .init(spec: spec, immediate: .imm8(0))
    }
    // Assume that the instruction is fine as-is, but allow it to be nil'd out if validation does not pass.
    var instruction: LR35902.Instruction? = .init(spec: spec)

    // Visit each operand, validating and extracting the statement's corresponding operand value when needed.
    try spec.visit { operand, shouldStop in
      guard let operand = operand else {
        // Base case of no operands.
        shouldStop = true
        return
      }
      let value = statement.operands[operand.index]
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
        instruction = .init(spec: spec, immediate: .imm16(numericValue))

      case LR35902.Instruction.Numeric.imm8, LR35902.Instruction.Numeric.simm8:
        guard var numericValue: UInt8 = RGBDS.integer(from: value) else {
          throw StringError(message: "Unable to represent \(value) as a \(UInt8.self)")
        }
        if case .jr = spec {
          // Relative jumps in assembly are written from the point of view of the instruction's beginning.
          numericValue = numericValue.subtractingReportingOverflow(UInt8(LR35902.InstructionSet.widths[spec]!.total)).partialValue
        }
        instruction = .init(spec: spec, immediate: .imm8(numericValue))

      case LR35902.Instruction.Numeric.ffimm8addr:
        guard let numericValue: UInt16 = RGBDS.integer(fromAddress: value) else {
          throw StringError(message: "Unable to represent \(value) as a \(UInt16.self)")
        }
        guard (numericValue & 0xFF00) == 0xFF00 else {
          instruction = nil
          shouldStop = true
          break
        }
        let lowerByteValue = UInt8(numericValue & 0xFF)
        instruction = .init(spec: spec, immediate: .imm8(lowerByteValue))

      case LR35902.Instruction.Numeric.sp_plus_simm8:
        guard let numericValue: UInt8 = RGBDS.integer(fromStackPointer: value) else {
          throw StringError(message: "Unable to represent \(value) as a \(UInt8.self)")
        }
        instruction = .init(spec: spec, immediate: .imm8(numericValue))

      case LR35902.Instruction.Numeric.imm16addr:
        guard let numericValue: UInt16 = RGBDS.integer(fromAddress: value) else {
          throw StringError(message: "Unable to represent \(value) as a \(UInt16.self)")
        }
        instruction = .init(spec: spec, immediate: .imm16(numericValue))
      default:
        break
      }
    }
    return instruction
  }

  /** Internal error type that can be thrown without needing awareness of the parsing context (i.e. line number). */
  private struct StringError: Swift.Error, Equatable {
    public let message: String
  }
}
