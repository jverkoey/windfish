import Foundation
import CPU

extension LR35902.Numeric {
  public var width: Int {
    switch self {
    case .sp_plus_simm8, .imm8, .simm8, .ffimm8addr, .zeroimm8: return 1
    case .imm16, .imm16addr: return 2
    default: return 0
    }
  }

  public var representation: String {
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

extension LR35902.Condition {
  public var representation: String {
    return "\(self)"
  }
}

extension LR35902.RestartAddress {
  public var representation: String {
    return "#"
  }
}

extension LR35902.Bit {
  public var representation: String {
    return "#"
  }
}
