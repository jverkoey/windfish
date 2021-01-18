import Foundation

import FoundationExtensions
import RGBDS

/** Turns LR3902 instructions into RGBDS assembly. */
public final class RGBDSDisassembler {

  /** The context within which an instruction should be turned into RGBDS assembly. */
  public struct Context {
    public init(address: LR35902.Address, bank: Cartridge.Bank, disassembly: Disassembler, argumentString: String?) {
      self.address = address
      self.bank = bank
      self.disassembly = disassembly
      self.argumentString = argumentString
    }

    public let address: LR35902.Address
    public let bank: Cartridge.Bank
    public let disassembly: Disassembler
    public let argumentString: String?
  }

  /**
   Creates an RGBDS statement for the given instruction.

   - Parameter instruction: Assembly code will be generated for this instruction.
   - Parameter disassembly: Optional additional context for the instruction, such as label names.
   - Parameter argumentString: Overrides any numerical value with the given string. Primarily used for macros.
   */
  public static func statement(for instruction: LR35902.Instruction, with context: Context? = nil) -> Statement {
    guard let opcode = LR35902.InstructionSet.opcodeStrings[instruction.spec] else {
      preconditionFailure("Could not find opcode for \(instruction.spec).")
    }

    var statement: Statement
    if let operands = operands(for: instruction, with: context) {
      // Operands should never be empty.
      precondition(operands.first(where: { $0.isEmpty }) == nil)

      statement = Statement(opcode: opcode, operands: operands)
    } else {
      statement = Statement(opcode: opcode)
    }

    statement.context = instruction.spec

    return statement
  }
}
