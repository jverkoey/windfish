import Foundation
import CPU

extension LR35902 {
  // MARK: - Lazily computed lookup tables for instruction and operands widths

  static var instructionWidths: [InstructionSpec: UInt16] = {
    return widths(for: instructionTable + instructionTableCB)
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
