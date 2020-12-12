import Foundation

import CPU
import FoundationExtensions
import RGBDS

extension LR35902.InstructionSet {
  public static func specs(for statement: RGBDS.Statement) -> [LR35902.Instruction.Spec]? {
    let representation = statement.tokenizedString
    guard let specs = tokenStringToSpecs[representation] else {
      return nil
    }
    return specs
  }
}

public final class RGBDSAssembler {

  public struct Error: Swift.Error, Equatable {
    let lineNumber: Int
    let error: String
  }

  public struct StringError: Swift.Error, Equatable {
    public let error: String
  }

  public static func assemble(assembly: String) -> (instructions: [LR35902.Instruction], data: Data, errors: [Error]) {
    var lineNumber = 1
    var buffer = Data()
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
        buffer.append(LR35902.InstructionSet.data(representing: instruction))

      } catch let error as StringError {
        errors.append(.init(lineNumber: lineNumber, error: error.error))
      } catch let error as RGBDSAssembler.Error {
        errors.append(error)
      } catch {
        errors.append(.init(lineNumber: lineNumber, error: "Unknown error"))
      }
    }
    return (instructions: instructions, data: buffer, errors: errors)
  }

  private static func instruction(from line: String) throws -> LR35902.Instruction? {
    guard let statement = RGBDS.Statement(fromLine: line) else {
      return nil
    }
    guard let specs = LR35902.InstructionSet.specs(for: statement) else {
      throw StringError(error: "No valid instruction found for \(statement.formattedString)")
    }
    let potentialInstructions: [LR35902.Instruction] = try specs.compactMap { spec in
      try RGBDSAssembler.instruction(from: statement, using: spec)
    }
    guard potentialInstructions.count == 1,
          let instruction = potentialInstructions.first else {
      throw StringError(error: "Unable to resolve instruction for \(statement.formattedString)")
    }
    return instruction
  }

  /**
   Attempts to create an instruction with the given specification from the given statement.

   If the specification has any numeric operand, then the operand's value will be extracted from the statement. If the
   operand value does not match the specification's value or width, then no instruction will be returned.

   It is assumed that the specifications loosely match the statement's tokenizedString representation.
   */
  public static func instruction(from statement: RGBDS.Statement, using spec: LR35902.Instruction.Spec) throws -> LR35902.Instruction? {
    if case LR35902.Instruction.Spec.stop = spec {
      // stop is always followed by a zero byte
      return .init(spec: spec, immediate: .imm8(0))
    }
    // Assume that the instruction is fine as-is, but allow it to be nil'd out if validation does not pass.
    var instruction: LR35902.Instruction? = .init(spec: spec)

    // Visit each operand, looking up the corresponding statement operand value for the current operand index when
    // needed.
    try spec.visit { operand, shouldStop in
      guard let operand = operand else {
        // Base case of no operands.
        shouldStop = true
        return
      }
      let value = statement.operands[operand.index]
      switch operand.value {

      case let restartAddress as LR35902.Instruction.RestartAddress:
        guard let numericValue: UInt16 = cast(string: value) else {
          throw StringError(error: "Unable to represent \(value) as a \(UInt16.self)")
        }
        if numericValue != restartAddress.rawValue {
          instruction = nil
          shouldStop = true
        }

      case let bit as LR35902.Instruction.Bit:
        guard let numericValue: UInt8 = cast(string: value) else {
          throw StringError(error: "Unable to represent \(value) as a \(UInt8.self)")
        }
        if numericValue != bit.rawValue {
          instruction = nil
          shouldStop = true
        }

      case LR35902.Instruction.Numeric.imm16:
        guard let numericValue: UInt16 = cast(string: value) else {
          throw StringError(error: "Unable to represent \(value) as a \(UInt16.self)")
        }
        instruction = .init(spec: spec, immediate: .imm16(numericValue))

      case LR35902.Instruction.Numeric.imm8, LR35902.Instruction.Numeric.simm8:
        guard var numericValue: UInt8 = cast(string: value) else {
          throw StringError(error: "Unable to represent \(value) as a \(UInt8.self)")
        }
        if case .jr = spec {
          // Relative jumps in assembly are written from the point of view of the instruction's beginning.
          numericValue = numericValue.subtractingReportingOverflow(UInt8(LR35902.InstructionSet.widths[spec]!.total)).partialValue
        }
        instruction = .init(spec: spec, immediate: .imm8(numericValue))

      case LR35902.Instruction.Numeric.ffimm8addr:
        guard let numericValue: UInt16 = cast(string: String(value.dropFirst().dropLast().trimmed())) else {
          throw StringError(error: "Unable to represent \(value) as a \(UInt16.self)")
        }
        if (numericValue & 0xFF00) != 0xFF00 {
          instruction = nil
          shouldStop = true
        }
        let lowerByteValue = UInt8(numericValue & 0xFF)
        instruction = .init(spec: spec, immediate: .imm8(lowerByteValue))

      case LR35902.Instruction.Numeric.sp_plus_simm8:
        guard let numericValue: UInt8 = cast(string: String(value.dropFirst(3).trimmed())) else {
          throw StringError(error: "Unable to represent \(value) as a \(UInt8.self)")
        }
        instruction = .init(spec: spec, immediate: .imm8(numericValue))

      case LR35902.Instruction.Numeric.imm16addr:
        guard let numericValue: UInt16 = cast(string: String(value.dropFirst().dropLast().trimmed())) else {
          throw StringError(error: "Unable to represent \(value) as a \(UInt16.self)")
        }
        instruction = .init(spec: spec, immediate: .imm16(numericValue))
      default:
        break
      }
    }
    return instruction
  }

}
