import Foundation

import CPU

extension Disassembler {
  /** Get the instruction at the given location, if one exists. */
  public func instruction(at location: Cartridge.Location) -> LR35902.Instruction? {
    guard code.contains(location.index) else {
      return nil
    }
    return instructionMap[location]
  }

  /** Register an instruction at the given location. */
  func register(instruction: LR35902.Instruction, at location: Cartridge.Location) {
    // Don't register instructions in the middle of existing instructions.
    if code.contains(location.index) && instructionMap[location] == nil {
      return
    }

    // Clear any existing instructions in this instruction's footprint.
    let instructionWidths: [LR35902.Instruction.Spec: CPU.InstructionWidth<UInt16>] = LR35902.InstructionSet.widths
    let instructionRange: Range<Cartridge.Location> = location..<(location + instructionWidths[instruction.spec]!.total)
    for clearLocation in instructionRange.dropFirst() {
      deleteInstruction(at: clearLocation)
    }

    instructionMap[location] = instruction
    // Set the code bit for the instruction's footprint.
    registerRegion(range: instructionRange, as: .code)
  }
}
