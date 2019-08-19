import Foundation

extension LR35902.InstructionSpec {
  public var opcodeWidth: UInt16 {
    guard let operands = Mirror(reflecting: self).children.first else {
      return 1
    }
    switch operands.value {
    case let childInstruction as LR35902.InstructionSpec:
      return 1 + childInstruction.opcodeWidth
    default:
      return 1
    }
  }

  public var operandWidth: UInt16 {
    guard let operands = Mirror(reflecting: self).children.first else {
      return 0
    }
    switch operands.value {
    case let childInstruction as LR35902.InstructionSpec:
      return childInstruction.operandWidth
    case let tuple as (LR35902.Condition?, LR35902.Numeric):
      return tuple.1.width
    case let tuple as (LR35902.Numeric, LR35902.Numeric):
      return tuple.0.width + tuple.1.width
    case let tuple as (LR35902.Bit, LR35902.Numeric):
      return tuple.1.width
    case let operand as LR35902.Numeric:
      return operand.width
    default: return 0
    }
  }

  public var representation: String {
    guard let operands = Mirror(reflecting: self).children.first else {
      return opcode
    }
    switch operands.value {
    case let childInstruction as LR35902.InstructionSpec:
      return childInstruction.representation
    case let tuple as (LR35902.Condition?, LR35902.Numeric):
      if let condition = tuple.0 {
        return "\(opcode) \(condition), \(tuple.1.representation)"
      } else {
        return "\(opcode) \(tuple.1.representation)"
      }
    case let tuple as (LR35902.Numeric, LR35902.Numeric):
      return "\(opcode) \(tuple.0.representation), \(tuple.1.representation)"
    case let tuple as (LR35902.Bit, LR35902.Numeric):
      return "\(opcode) #, \(tuple.1.representation)"
    case let operand as LR35902.Numeric:
      return "\(opcode) \(operand.representation)"
    case let condition as LR35902.Condition:
      return "\(opcode) \(condition)"
    case is LR35902.RestartAddress:
      return "\(opcode) #"
    default:
      return opcode
    }
  }
}

extension LR35902.Numeric {
  var width: UInt16 {
    switch self {
    case .sp_plus_simm8, .imm8, .simm8, .ffimm8addr, .zeroimm8: return 1
    case .imm16, .imm16addr: return 2
    default: return 0
    }
  }

  var representation: String {
    switch self {
    case .hladdr:
      return "[hl]"
    case .bcaddr:
      return "[bc]"
    case .imm16addr:
      return "[#]"
    case .ffimm8addr:
      return "[#]"
    case .sp_plus_simm8:
      return "sp+#"
    case .imm8, .simm8, .imm16:
      return "#"
    default:
      return "\(self)"
    }
  }
}
