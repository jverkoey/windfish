import Foundation
import CPU

extension LR35902.Instruction.Numeric {
  public var representation: CPUInstructionOperandRepresentation {
    switch self {
    case .bcaddr:
      return .specific("[bc]")
    case .deaddr:
      return .specific("[de]")
    case .hladdr:
      return .specific("[hl]")
    case .imm16addr, .ffimm8addr:
      return .address
    case .sp_plus_simm8:
      return .specific("sp+#")
    case .imm8, .simm8, .imm16:
      return .numeric
    default:
      return .specific("\(self)")
    }
  }
}

extension LR35902.Instruction.RestartAddress {
  public var representation: CPUInstructionOperandRepresentation {
    return .numeric
  }
}

extension LR35902.Instruction.Bit {
  public var representation: CPUInstructionOperandRepresentation {
    return .numeric
  }
}
