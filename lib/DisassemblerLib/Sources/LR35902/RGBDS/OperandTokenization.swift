import Foundation

import RGBDS

extension LR35902.Instruction.Numeric: InstructionOperandTokenizable {
  public var token: InstructionOperandToken {
    switch self {
    case .bcaddr:
      return .specific("[bc]")
    case .deaddr:
      return .specific("[de]")
    case .hladdr:
      return .specific("[hl]")
    case .imm16addr:
      return .address
    case .ffimm8addr:
      return .ffaddress
    case .sp_plus_simm8:
      return .stackPointerOffset
    case .imm8, .simm8, .imm16:
      return .numeric
    default:
      return .specific("\(self)")
    }
  }
}

extension LR35902.Instruction.RestartAddress: InstructionOperandTokenizable {
  public var token: InstructionOperandToken {
    return .numeric
  }
}

extension LR35902.Instruction.Bit: InstructionOperandTokenizable {
  public var token: InstructionOperandToken {
    return .numeric
  }
}
