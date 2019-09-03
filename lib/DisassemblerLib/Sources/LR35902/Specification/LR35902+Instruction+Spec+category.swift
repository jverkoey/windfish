import Foundation
import CPU

extension LR35902.Instruction.Spec {
  public var category: CPU.InstructionCategory? {
    switch self {
    case .call: return .call
    case .ret, .reti: return .ret
    default: return nil
    }
  }
}
