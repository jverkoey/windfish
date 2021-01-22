import Foundation

import CPU

extension Disassembler {
  /** Get the instruction at the given location, if one exists. */
  public func instruction(at location: Cartridge.Location) -> LR35902.Instruction? {
    guard code.contains(location.index) else {
      return nil
    }
    return instructionMap[Cartridge._Location(truncatingIfNeeded: location.index)]
  }

  /** Register an instruction at the given location. */
  func register(instruction: LR35902.Instruction, at location: Cartridge.Location) {
    let index = location.index

    // Don't register instructions in the middle of existing instructions.
    if code.contains(index) && instructionMap[Cartridge._Location(truncatingIfNeeded: index)] == nil {
      return
    }

    // Clear any existing instructions in this instruction's footprint.
    let instructionWidths: [LR35902.Instruction.Spec: CPU.InstructionWidth<UInt16>] = LR35902.InstructionSet.widths
    let instructionWidth: Int = Int(truncatingIfNeeded: instructionWidths[instruction.spec]!.total)
    let instructionRange: Range<Int> = index..<(index + instructionWidth)
    for index in instructionRange.dropFirst() {
      let location = Cartridge._Location(truncatingIfNeeded: index)
      guard let existingInstruction = instructionMap[location] else {
        continue
      }
      deleteInstruction(at: location)
    }

    instructionMap[Cartridge._Location(truncatingIfNeeded: index)] = instruction
    // Set the code bit for the instruction's footprint.
    registerRegion(range: instructionRange, as: .code)
  }
}