import Foundation

extension LR35902.InstructionSpec {
  var opcode: String {
    if let child = Mirror(reflecting: self).children.first {
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
    case let tuple as (LR35902.Operand, LR35902.Condition?):
      return tuple.0.byteWidth
    case let tuple as (LR35902.Operand, LR35902.Operand):
      return tuple.0.byteWidth + tuple.1.byteWidth
    case let tuple as (LR35902.Bit, LR35902.Operand):
      return tuple.1.byteWidth
    case let operand as LR35902.Operand:
      return operand.byteWidth
    default: return 0
    }
  }
}

extension LR35902.Operand {
  var byteWidth: UInt16 {
    switch self {
    case .spPlusImmediate8Signed, .immediate8, .immediate8signed, .ffimmediate8Address: return 1
    case .immediate16, .immediate16address: return 2
    default: return 0
    }
  }
}
