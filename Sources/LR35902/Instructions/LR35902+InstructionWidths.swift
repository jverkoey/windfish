import Foundation

extension LR35902 {
  // MARK: - Lazily computed lookup tables for instruction and operands widths

  static var instructionWidths: [InstructionSpec: UInt16] = {
    var widths: [InstructionSpec: UInt16] = [:]
    instructionTable.forEach { spec in
      widths[spec] = 1 + spec.operandWidth
    }
    instructionTableCB.forEach { spec in
      widths[spec] = 2 + spec.operandWidth
    }
    return widths
  }()

  static var operandWidths: [UInt16] = {
    instructionTable.map { spec in
      spec.operandWidth
    }
  }()
  static var operandWidthsCB: [UInt16] = {
    instructionTableCB.map { spec in
      spec.operandWidth
    }
  }()
}
