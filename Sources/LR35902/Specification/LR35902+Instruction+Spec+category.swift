import Foundation
import CPU

extension LR35902.Instruction.Spec {
  public var category: CPU.InstructionCategory? {
    switch self {
    case .call: return .call
    default: return nil
    }
  }
}
