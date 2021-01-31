import Foundation

extension Disassembler {
  static func disassembleInstructionSpec(at pc: inout LR35902.Address, memory: DisassemblerMemory) -> LR35902.Instruction.Spec {
    // Fetch
    let instructionByte = memory.read(from: pc)
    pc += 1

    // Decode
    let spec = LR35902.InstructionSet.table[Int(truncatingIfNeeded: instructionByte)]
    if let prefixTable = LR35902.InstructionSet.prefixTables[spec] {
      // Fetch
      let cbInstructionByte = memory.read(from: pc)
      pc += 1

      // Decode
      return prefixTable[Int(truncatingIfNeeded: cbInstructionByte)]
    }
    return spec
  }

  static func disassembleInstruction(at address: inout LR35902.Address, memory: DisassemblerMemory) -> LR35902.Instruction {
    let spec = disassembleInstructionSpec(at: &address, memory: memory)

    guard let instructionWidth = LR35902.InstructionSet.widths[spec] else {
      preconditionFailure("\(spec) is missing its width, implying a misconfiguration of the instruction set."
                            + " Verify that all specifications are computing and storing a corresponding width in the"
                            + " instruction set's width table.")
    }

    if instructionWidth.operand > 0 {
      var operandBytes: [UInt8] = []
      for _ in 0..<Int(instructionWidth.operand) {
        let byte = memory.read(from: address)
        address += 1
        operandBytes.append(byte)
      }
      return LR35902.Instruction(spec: spec, immediate: LR35902.Instruction.ImmediateValue(data: Data(operandBytes)))
    }

    return LR35902.Instruction(spec: spec, immediate: nil)
  }
}
