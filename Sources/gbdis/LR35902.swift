import Foundation

class LR35902 {
  var pc: UInt16 = 0
  var bank: UInt8 = 0

  let rom: Data
  init(rom: Data) {
    self.rom = rom
  }

  var numberOfBanks: UInt8 {
    return UInt8(UInt32(rom.count) / LR35902.bankSize)
  }

  let disassembly = Disassembly()

  struct BankedAddress: Hashable {
    let bank: UInt8
    let address: UInt16
  }

  static func label(at pc: UInt16, in bank: UInt8) -> String {
    if pc < 0x4000 {
      return "toc_00_\(pc.hexString)"
    }
    return "toc_\(bank.hexString)_\(pc.hexString)"
  }

  struct Instruction: CustomStringConvertible {
    let spec: InstructionSpec
    let width: UInt16
    let immediate8: UInt8?
    let immediate16: UInt16?

    init(spec: InstructionSpec, width: UInt16, immediate8: UInt8? = nil, immediate16: UInt16? = nil) {
      self.spec = spec
      self.width = width
      self.immediate8 = immediate8
      self.immediate16 = immediate16
    }

    func describe(with cpu: LR35902? = nil) -> String {
      if let operandDescription = operandDescription(with: cpu) {
        let opcodeName = "\(spec.name)".padding(toLength: 5, withPad: " ", startingAt: 0)
        return "\(opcodeName) \(operandDescription)"
      } else {
        return "\(spec.name)"
      }
    }

    var description: String {
      if let operandDescription = operandDescription() {
        let opcodeName = "\(spec.name)".padding(toLength: 5, withPad: " ", startingAt: 0)
        return "\(opcodeName) \(operandDescription)"
      } else {
        return "\(spec.name)"
      }
    }

    func operandDescription(with cpu: LR35902? = nil) -> String? {
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
      case let InstructionSpec.jr(operand, condition) where operand == .immediate8:
        let address: String
        if let cpu = cpu {
          let jumpAddress = cpu.pc + width + UInt16(immediate8!)
          if cpu.disassembly.transfersOfControl(at: jumpAddress, in: cpu.bank) != nil {
            address = "toc_\(cpu.bank.hexString)_\(jumpAddress.hexString)"
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
      case let tuple as (Operand, Operand):
        return "\(describe(operand: tuple.0)), \(describe(operand: tuple.1))"
      case let tuple as (Bit, Operand):
        return "\(tuple.0), \(describe(operand: tuple.1))"
      case let operand as Operand:
        return "\(describe(operand: operand))"
      case let address as RestartAddress:
        return "\(address)".replacingOccurrences(of: "x", with: "$")
      default:
        return nil
      }
    }

    func describe(operand: Operand) -> String {
      switch operand {
      case .immediate8:           return "$\(immediate8!.hexString)"
      case .immediate16:          return "$\(immediate16!.hexString)"
      case .ffimmediate8Address:  return "[$FF00+$\(immediate8!.hexString)]"
      case .immediate16address:   return "[$\(immediate16!.hexString)]"
      case .hlAddress:            return "[hl]"
      default:                    return "\(operand)"
      }
    }
  }

  func disassemble(range: Range<UInt16>, inBank bankInitial: UInt8) {
    var jumpAddresses = Set<BankedAddress>()
    jumpAddresses.insert(BankedAddress(bank: bankInitial, address: range.lowerBound))

    var visitedAddresses = IndexSet()
    var isFirst = true

    while !jumpAddresses.isEmpty {
      let address = jumpAddresses.removeFirst()
      bank = address.bank
      pc = address.address

      var previousInstruction: Instruction? = nil
      linear_sweep: while (!isFirst && ((bank == 0 && pc < 0x4000) || (bank != 0 && pc < 0x8000))) || pc < range.upperBound {
        let byte = rom[Int(pc)]
        var opcodeWidth: UInt16 = 1
        guard var spec = LR35902.opcodeDescription[byte] else {
          pc += opcodeWidth
          continue
        }
        if case .invalid = spec {
          pc += opcodeWidth
          continue
        }
        if case .cb = spec {
          let byte = rom[Int(pc + 1)]
          opcodeWidth += 1
          guard let cbInstruction = LR35902.cbOpcodeDescription[byte] else {
            pc += opcodeWidth
            continue
          }
          if case .invalid = spec {
            pc += opcodeWidth
            continue
          }
          spec = cbInstruction
        }

        let instructionWidth = opcodeWidth + spec.operandWidth
        let instruction: Instruction
        switch spec.operandWidth {
        case 1:
          instruction = Instruction(spec: spec, width: instructionWidth, immediate8: rom[Int(pc + opcodeWidth)])
        case 2:
          let low = UInt16(rom[Int(pc + opcodeWidth)])
          let high = UInt16(rom[Int(pc + opcodeWidth + 1)]) << 8
          let immediate16 = high | low
          instruction = Instruction(spec: spec, width: instructionWidth, immediate16: immediate16)
        default:
          instruction = Instruction(spec: spec, width: instructionWidth)
        }

        disassembly.register(instruction: instruction, at: pc, in: bank)

        let nextPc = pc + instructionWidth

        let lowerBound = Int(LR35902.romAddress(for: pc, in: bank))
        visitedAddresses.insert(integersIn: lowerBound..<(lowerBound + Int(instructionWidth)))

        switch spec {
        case .ld(.immediate16address, .a):
          if (0x2000..<0x4000).contains(instruction.immediate16!),
             let previousInstruction = previousInstruction,
             case .ld(.a, .immediate8) = previousInstruction.spec {
            bank = previousInstruction.immediate8!
          }
          break
        case .jr(.immediate8, let condition):
          let relativeJumpAmount = UInt16(rom[Int(pc + 1)])
          let jumpTo = nextPc + relativeJumpAmount
          if !visitedAddresses.contains(Int(LR35902.romAddress(for: jumpTo, in: bank))) {
            jumpAddresses.insert(BankedAddress(bank: bank, address: jumpTo))
          }
          disassembly.registerTransferOfControl(to: jumpTo, in: bank, from: pc, kind: .jr)

          if condition == nil {
            break linear_sweep
          }

        case .jp(.immediate16, let condition):
          let jumpLow = UInt16(rom[Int(pc + 1)])
          let jumpHigh = UInt16(rom[Int(pc + 2)]) << 8
          let jumpTo = jumpHigh | jumpLow
          if !visitedAddresses.contains(Int(LR35902.romAddress(for: jumpTo, in: bank))) {
            jumpAddresses.insert(BankedAddress(bank: bank, address: jumpTo))
          }
          disassembly.registerTransferOfControl(to: jumpTo, in: bank, from: pc, kind: .jp)

          if condition == nil {
            break linear_sweep
          }

        case .call(.immediate16, _):
          let jumpLow = UInt16(rom[Int(pc + 1)])
          let jumpHigh = UInt16(rom[Int(pc + 2)]) << 8
          let jumpTo = jumpHigh | jumpLow
          if !visitedAddresses.contains(Int(LR35902.romAddress(for: jumpTo, in: bank))) {
            jumpAddresses.insert(BankedAddress(bank: bank, address: jumpTo))
          }
          disassembly.registerTransferOfControl(to: jumpTo, in: bank, from: pc, kind: .call)

        case .jp(_, nil), .ret:
          break linear_sweep

        default:
          break
        }

        pc = nextPc
        previousInstruction = instruction
      }

      isFirst = false
    }
  }

  static let bankSize: UInt32 = 0x4000
}
