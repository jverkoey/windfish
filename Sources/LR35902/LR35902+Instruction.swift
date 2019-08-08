import Foundation

extension LR35902 {
  public struct Instruction {
    public let spec: InstructionSpec
    public let width: UInt16
    public let immediate8: UInt8?
    public let immediate16: UInt16?

    init(spec: InstructionSpec, width: UInt16, immediate8: UInt8? = nil, immediate16: UInt16? = nil) {
      self.spec = spec
      self.width = width
      self.immediate8 = immediate8
      self.immediate16 = immediate16
    }

    public func describe(with cpu: LR35902? = nil) -> String {
      if let operandDescription = operandDescription(with: cpu) {
        let opcodeName = "\(spec.name)".padding(toLength: 4, withPad: " ", startingAt: 0)
        return "\(opcodeName) \(operandDescription)"
      } else {
        return "\(spec.name)"
      }
    }

    private func operandDescription(with cpu: LR35902? = nil) -> String? {
      switch spec {
      case let InstructionSpec.jp(operand, condition) where operand == .immediate16,
           let InstructionSpec.call(operand, condition) where operand == .immediate16:
        let address: String
        if let cpu = cpu, cpu.disassembly.transfersOfControl(at: immediate16!, in: cpu.bank) != nil {
          address = LR35902.label(at: immediate16!, in: cpu.bank)
        } else {
          address = describe(operand: operand)
        }

        if let condition = condition {
          return "\(condition), \(address)"
        } else {
          return "\(address)"
        }
      case let InstructionSpec.jr(operand, condition) where operand == .immediate8signed:
        let address: String
        if let cpu = cpu {
          let jumpAddress = (cpu.pc + width).advanced(by: Int(Int8(bitPattern: immediate8!)))
          if cpu.disassembly.transfersOfControl(at: jumpAddress, in: cpu.bank) != nil {
            address = LR35902.label(at: jumpAddress, in: cpu.bank)
          } else {
            address = describe(operand: operand)
          }
        } else {
          address = describe(operand: operand)
        }

        if let condition = condition {
          return "\(condition), \(address)"
        } else {
          return "\(address)"
        }
      default:
        break
      }
      let mirror = Mirror(reflecting: spec)
      guard let operands = mirror.children.first else {
        return nil
      }
      switch operands.value {
      case let tuple as (Operand, Condition?):
        if let condition = tuple.1 {
          return "\(condition), \(describe(operand: tuple.0))"
        } else {
          return "\(describe(operand: tuple.0))"
        }
      case let condition as Condition:
        return "\(condition)"
      case let tuple as (Operand, Operand):
        return "\(describe(operand: tuple.0)), \(describe(operand: tuple.1))"
      case let tuple as (Bit, Operand):
        return "\(tuple.0.rawValue), \(describe(operand: tuple.1))"
      case let operand as Operand:
        return "\(describe(operand: operand))"
      case let address as RestartAddress:
        return "\(address)".replacingOccurrences(of: "x", with: "$")
      default:
        return nil
      }
    }

    private func describe(operand: Operand) -> String {
      switch operand {
      case .immediate8:           return "$\(immediate8!.hexString)"
      case .immediate8signed:
        let byte = immediate8!
        if (byte & UInt8(0x80)) != 0 {
          return "@-$\((0xff - byte + 1 - 2).hexString)"
        } else {
          return "@+$\((byte + 2).hexString)"
        }
      case .immediate16:          return "$\(immediate16!.hexString)"
      case .ffimmediate8Address:  return "[$FF00+$\(immediate8!.hexString)]"
      case .immediate16address:   return "[$\(immediate16!.hexString)]"
      case .bcAddress:            return "[bc]"
      case .deAddress:            return "[de]"
      case .hlAddress:            return "[hl]"
      case .ffccAddress:          return "[$ff00+c]"
      case .spPlusImmediate8Signed:
        let signedByte = Int8(bitPattern: immediate8!)
        if signedByte < 0 {
          return "sp-$\((0xff - immediate8! + 1).hexString)"
        } else {
          return "sp+$\(immediate8!.hexString)"
        }
      default:                    return "\(operand)"
      }
    }
  }
}
