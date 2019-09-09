import Foundation
import CPU

extension LR35902.Instruction {
  // MARK: - Lazily computed lookup table for instruction widths

  static var opcodes: [Spec: String] = {
    return (table + tableCB).reduce(into: [:]) { accumulator, spec in
      accumulator[spec] = spec.opcode
    }
  }()
}
