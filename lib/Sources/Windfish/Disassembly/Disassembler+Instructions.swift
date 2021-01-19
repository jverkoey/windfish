import Foundation

import CPU

extension Disassembler {
  /** Get the instruction at the given location, if one exists. */
  public func instruction(at pc: LR35902.Address, in bank: Cartridge.Bank) -> LR35902.Instruction? {
    precondition(bank > 0)
    guard let location: Cartridge.Location = Cartridge.location(for: pc, in: bank) else {
      return nil
    }
    guard code.contains(Int(truncatingIfNeeded: location)) else {
      return nil
    }
    return instructionMap[location]
  }

  /** Register an instruction at the given location. */
  func register(instruction: LR35902.Instruction, at pc: LR35902.Address, in bank: Cartridge.Bank) {
    precondition(bank > 0)
    guard let location = Cartridge.location(for: pc, in: bank) else {
      return
    }
    let intLocation = Int(truncatingIfNeeded: location)

    // Don't register instructions in the middle of existing instructions.
    if code.contains(intLocation) && instructionMap[location] == nil {
      return
    }

    // Clear any existing instructions in this instruction's footprint.
    let instructionWidths: [LR35902.Instruction.Spec: CPU.InstructionWidth<UInt16>] = LR35902.InstructionSet.widths
    let instructionWidth: Int = Int(truncatingIfNeeded: instructionWidths[instruction.spec]!.total)
    let instructionRange: Range<Int> = intLocation..<(intLocation + instructionWidth)
    for index in instructionRange.dropFirst() {
      let location = Cartridge.Location(truncatingIfNeeded: index)
      guard let existingInstruction = instructionMap[location] else {
        continue
      }
      instructionMap[location] = nil

      // Reset the code bit for the existing instruction's footprint.
      let existingInstructionWidth: Int = Int(truncatingIfNeeded: instructionWidths[existingInstruction.spec]!.total)
      code.remove(integersIn: index..<(index + existingInstructionWidth))
    }

    instructionMap[location] = instruction
    // Set the code bit for the instruction's footprint.
    code.insert(integersIn: instructionRange)
  }
}
