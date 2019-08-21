import Foundation

extension LR35902.Instruction.Numeric {
  public var width: Int {
    switch self {
    case .sp_plus_simm8, .imm8, .simm8, .ffimm8addr, .zeroimm8: return 1
    case .imm16, .imm16addr: return 2
    default: return 0
    }
  }
}
