import Foundation

import CPU

extension Disassembler.BankRouter {
  /** Registers a range as a specific region category. Will clear any existing regions in the range. */
  public func instruction(at location: Cartridge.Location) -> LR35902.Instruction? {
    return bankWorkers[Int(truncatingIfNeeded: location.bankIndex)].instruction(at: location)
  }

  /** Registers a range as a specific region category. Will clear any existing regions in the range. */
  public func type(at location: Cartridge.Location) -> String? {
    return bankWorkers[Int(truncatingIfNeeded: location.bankIndex)].typeAtLocation[location.address]
  }
}

extension Disassembler.BankWorker {
  /** Get the instruction at the given location, if one exists. */
  public func instruction(at location: Cartridge.Location) -> LR35902.Instruction? {
    assert(location.bankIndex == bank)
    guard code.contains(location.index) else {
      return nil
    }
    return instructionMap[location.address]
  }

  /** Register an instruction at the given location. */
  func register(instruction: LR35902.Instruction, at location: Cartridge.Location) {
    assert(location.bankIndex == bank)
    guard instructionMap[location.address] == nil else {
      return
    }
    // Don't register instructions in the middle of existing instructions.
    if code.contains(location.index) {
      return
    }

    // Clear any existing instructions in this instruction's footprint.
    let instructionWidths: [LR35902.Instruction.Spec: CPU.InstructionWidth<UInt16>] = LR35902.InstructionSet.widths
    let instructionRange: Range<Cartridge.Location> = location..<(location + instructionWidths[instruction.spec]!.total)
    for clearLocation in instructionRange.dropFirst() {
      deleteInstruction(at: clearLocation)
    }

    instructionMap[location.address] = instruction
    // Set the code bit for the instruction's footprint.
    registerRegion(range: instructionRange, as: .code)
  }
}
