import Foundation
import Disassembler
import CPU

extension LR35902.Instruction.Spec: InstructionSpecDisassemblyInfo {
  public var category: InstructionCategory? {
    switch self {
    case .call: return .call
    case .ret, .reti: return .ret
    default: return nil
    }
  }
}

extension LR35902.Instruction.Numeric: InstructionOperandAssemblyRepresentable {
  public var representation: InstructionOperandAssemblyRepresentation {
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

extension LR35902.Instruction.RestartAddress: InstructionOperandAssemblyRepresentable {
  public var representation: InstructionOperandAssemblyRepresentation {
    return .numeric
  }
}

extension LR35902.Instruction.Bit: InstructionOperandAssemblyRepresentable {
  public var representation: InstructionOperandAssemblyRepresentation {
    return .numeric
  }
}
