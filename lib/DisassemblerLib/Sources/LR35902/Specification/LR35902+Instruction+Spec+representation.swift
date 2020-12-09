import Foundation
import CPU

extension LR35902.Instruction.Numeric {
  public var representation: CPU.InstructionOperandAssemblyRepresentation {
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

extension LR35902.Instruction.RestartAddress {
  public var representation: CPU.InstructionOperandAssemblyRepresentation {
    return .numeric
  }
}

extension LR35902.Instruction.Bit {
  public var representation: CPU.InstructionOperandAssemblyRepresentation {
    return .numeric
  }
}
