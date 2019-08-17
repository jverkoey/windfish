import Foundation

extension LR35902.InstructionSpec {
  var opcode: String {
    if let child = Mirror(reflecting: self).children.first {
      if let childInstruction = child.value as? LR35902.InstructionSpec {
        return childInstruction.opcode
      }
      return child.label!
    } else {
      return "\("\(self)".split(separator: ".").last!)"
    }
  }
  var operandWidth: UInt16 {
    guard let operands = Mirror(reflecting: self).children.first else {
      return 0
    }
    switch operands.value {
    case let childInstruction as LR35902.InstructionSpec:
      return childInstruction.operandWidth
    case let tuple as (LR35902.Operand, LR35902.Condition?):
      return tuple.0.width
    case let tuple as (LR35902.Operand, LR35902.Operand):
      return tuple.0.width + tuple.1.width
    case let tuple as (LR35902.Bit, LR35902.Operand):
      return tuple.1.width
    case let operand as LR35902.Operand:
      return operand.width
    default: return 0
    }
  }

  var representation: String {
    guard let operands = Mirror(reflecting: self).children.first else {
      return opcode
    }
    switch operands.value {
    case let childInstruction as LR35902.InstructionSpec:
      return childInstruction.representation
    case let tuple as (LR35902.Operand, LR35902.Condition?):
      if let condition = tuple.1 {
        return "\(opcode) \(condition), \(tuple.0.representation)"
      } else {
        return "\(opcode) \(tuple.0.representation)"
      }
    case let tuple as (LR35902.Operand, LR35902.Operand):
      return "\(opcode) \(tuple.0.representation), \(tuple.1.representation)"
    case let tuple as (LR35902.Bit, LR35902.Operand):
      return "\(opcode) \(tuple.0.rawValue), \(tuple.1)"
    case let operand as LR35902.Operand:
      return "\(opcode) \(operand.representation)"
    case let condition as LR35902.Condition:
      return "\(opcode) \(condition)"
    case let restartAddress as (LR35902.RestartAddress):
      return "\(opcode) \(restartAddress)"
    default:
      return opcode
    }
  }
}

extension LR35902.Operand {
  var width: UInt16 {
    switch self {
    case .spPlusImmediate8Signed, .immediate8, .immediate8signed, .ffimmediate8Address, .zero8: return 1
    case .immediate16, .immediate16address: return 2
    default: return 0
    }
  }

  var representation: String {
    switch self {
    case .hlAddress, .bcAddress,
         .immediate8, .immediate8signed,
         .immediate16, .immediate16address,
         .spPlusImmediate8Signed,
         .ffimmediate8Address:
      return "numeric"
    default:
      return "\(self)"
    }
  }
}
