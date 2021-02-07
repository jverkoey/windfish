import Foundation

import LR35902
import RGBDS
@testable import Windfish

extension RGBDSAssembler {
  /** An error that occurred during parsing of RGBDS assembly. */
  struct Error: Swift.Error, Equatable {
    /** The line number on which the error occurred. Uses 1-based indexing. */
    let lineNumber: Int

    /** A description of the error that occurred. */
    let message: String
  }

  /**
   Assembles the given assembly code into an array of instructions.

   If any portion of the assembly fails, then errors will also be returned.
   */
  static func assemble(assembly: String) -> (instructions: ContiguousArray<LR35902.Instruction>, errors: ContiguousArray<Error>) {
    var lineNumber: Int = 1
    var instructions = ContiguousArray<LR35902.Instruction>()
    var errors = ContiguousArray<Error>()

    assembly.enumerateLines { (line, stop) in
      defer {
        lineNumber += 1
      }

      do {
        guard let instruction = try instruction(from: line) else {
          return
        }
        instructions.append(instruction)

      } catch let error as RGBDSAssembler.StringError {
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
}
