import Foundation
import CPU

extension LR35902.Instruction {
  // MARK: - Lazily computed lookup table for instruction widths

  static var widths: [Spec: InstructionWidth<UInt16>] = {
    return CPU.widths(for: table + tableCB)
  }()
}
