import Foundation

import Disassembler

extension LR35902.Instruction.Spec: InstructionSpecDisassemblyInfo {
  public var category: InstructionCategory? {
    switch self {
    case .call: return .call
    case .ret, .reti: return .ret
    default: return nil
    }
  }
}
