import Foundation

public final class RGBDSAssembly {

  public static let maxOpcodeNameLength = 4
  public static func assembly(for instruction: LR35902.Instruction, with cpu: LR35902? = nil) -> String {
    if let operand = operandAssembly(for: instruction, with: cpu) {
      let opcodeName = instruction.spec.opcode.padding(toLength: maxOpcodeNameLength, withPad: " ", startingAt: 0)
      return "\(opcodeName) \(operand)"
    } else {
      return instruction.spec.opcode
    }
  }

  public static func assembly(for bytes: [UInt8]) -> String {
    let opcode = "db".padding(toLength: maxOpcodeNameLength, withPad: " ", startingAt: 0)
    let operand = bytes.map { "$\($0.hexString)" }.joined(separator: ", ")
    return "\(opcode) \(operand)"
  }

  private static func operandAssembly(for instruction: LR35902.Instruction, with cpu: LR35902? = nil) -> String? {
    switch instruction.spec {
    case let LR35902.InstructionSpec.jp(operand, condition) where operand == .immediate16,
         let LR35902.InstructionSpec.call(operand, condition) where operand == .immediate16:
      let address: String
      if let cpu = cpu, cpu.disassembly.transfersOfControl(at: instruction.immediate16!, in: cpu.bank) != nil {
        address = LR35902.label(at: instruction.immediate16!, in: cpu.bank)
        if let condition = condition {
          return "\(condition), \(address)"
        } else {
          return "\(address)"
        }
      }

    case let LR35902.InstructionSpec.jr(operand, condition) where operand == .immediate8signed:
      let address: String
      if let cpu = cpu {
        let jumpAddress = (cpu.pc + instruction.width).advanced(by: Int(Int8(bitPattern: instruction.immediate8!)))
        if cpu.disassembly.transfersOfControl(at: jumpAddress, in: cpu.bank) != nil {
          address = LR35902.label(at: jumpAddress, in: cpu.bank)
          if let condition = condition {
            return "\(condition), \(address)"
          } else {
            return "\(address)"
          }
        }
      }

    default:
      break
    }
    let mirror = Mirror(reflecting: instruction.spec)
    guard let operands = mirror.children.first else {
      return nil
    }
    switch operands.value {
    case let tuple as (LR35902.Operand, LR35902.Condition?):
      if let condition = tuple.1 {
        return "\(condition), \(describe(for: instruction, operand: tuple.0))"
      } else {
        return "\(describe(for: instruction, operand: tuple.0))"
      }
    case let condition as LR35902.Condition:
      return "\(condition)"
    case let tuple as (LR35902.Operand, LR35902.Operand):
      return "\(describe(for: instruction, operand: tuple.0)), \(describe(for: instruction, operand: tuple.1))"
    case let tuple as (LR35902.Bit, LR35902.Operand):
      return "\(tuple.0.rawValue), \(describe(for: instruction, operand: tuple.1))"
    case let operand as LR35902.Operand:
      return "\(describe(for: instruction, operand: operand))"
    case let address as LR35902.RestartAddress:
      return "\(address)".replacingOccurrences(of: "x", with: "$")
    default:
      return nil
    }
  }

  private static func describe(for instruction: LR35902.Instruction, operand: LR35902.Operand) -> String {
    switch operand {
    case .immediate8:           return "$\(instruction.immediate8!.hexString)"
    case .immediate8signed:
      let byte = instruction.immediate8!
      if (byte & UInt8(0x80)) != 0 {
        return "@-$\((0xff - byte + 1 - 2).hexString)"
      } else {
        return "@+$\((byte + 2).hexString)"
      }
    case .immediate16:          return "$\(instruction.immediate16!.hexString)"
    case .ffimmediate8Address:  return "[$FF00+$\(instruction.immediate8!.hexString)]"
    case .immediate16address:   return "[$\(instruction.immediate16!.hexString)]"
    case .bcAddress:            return "[bc]"
    case .deAddress:            return "[de]"
    case .hlAddress:            return "[hl]"
    case .ffccAddress:          return "[$ff00+c]"
    case .spPlusImmediate8Signed:
      let signedByte = Int8(bitPattern: instruction.immediate8!)
      if signedByte < 0 {
        return "sp-$\((0xff - instruction.immediate8! + 1).hexString)"
      } else {
        return "sp+$\(instruction.immediate8!.hexString)"
      }
    default:                    return "\(operand)"
    }
  }
}
