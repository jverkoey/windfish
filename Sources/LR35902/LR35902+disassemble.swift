import Foundation

extension LR35902 {
  public func disassemble(range: Range<UInt16>, inBank bankInitial: UInt8) {
    var jumpAddresses: [BankedAddress] = []
    jumpAddresses.append(BankedAddress(bank: bankInitial, address: range.lowerBound))

    var visitedAddresses = IndexSet()
    var isFirst = true

    while !jumpAddresses.isEmpty {
      let address = jumpAddresses.removeFirst()
      bank = address.bank
      pc = address.address

      var previousInstruction: Instruction? = nil
      linear_sweep: while (!isFirst && ((bank == 0 && pc < 0x4000) || (bank != 0 && pc < 0x8000))) || pc < range.upperBound {
        let byte = Int(self[pc, bank])

        var spec = LR35902.instructionTable[byte]

        var opcodeWidth: UInt16
        var operandWidth: UInt16
        switch spec {
        case .invalid:
          pc += 1
          continue

        case .cb:
          let byteCB = Int(self[pc + 1, bank])
          let cbInstruction = LR35902.instructionTableCB[byteCB]
          if case .invalid = spec {
            pc += 2
            continue
          }
          spec = cbInstruction

          opcodeWidth = 2
          operandWidth = LR35902.operandWidthsCB[byteCB]

        default:
          opcodeWidth = 1
          operandWidth = LR35902.operandWidths[byte]
          break
        }

        let instructionWidth = opcodeWidth + operandWidth
        let instruction: Instruction
        switch operandWidth {
        case 1:
          instruction = Instruction(spec: spec,
                                    width: instructionWidth,
                                    immediate8: self[pc + opcodeWidth, bank])
        case 2:
          let low = UInt16(self[pc + opcodeWidth, bank])
          let high = UInt16(self[pc + opcodeWidth + 1, bank]) << 8
          let immediate16 = high | low
          instruction = Instruction(spec: spec, width: instructionWidth, immediate16: immediate16)
        default:
          instruction = Instruction(spec: spec, width: instructionWidth)
        }

        if case .stop = spec {
          // STOP must be followed by 0
          if instruction.immediate8 != 0 {
            pc += 1
            continue
          }
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
            disassembly.register(bankChange: previousInstruction.immediate8!, at: pc, in: bank)

            bank = previousInstruction.immediate8!
          }
          break
        case .jr(.immediate8signed, let condition):
          let relativeJumpAmount = Int8(bitPattern: instruction.immediate8!)
          let jumpTo = nextPc.advanced(by: Int(relativeJumpAmount))
          if !visitedAddresses.contains(Int(LR35902.romAddress(for: jumpTo, in: bank))) {
            jumpAddresses.append(BankedAddress(bank: bank, address: jumpTo))
          }
          disassembly.registerTransferOfControl(to: jumpTo, in: bank, from: pc, kind: .jr)

          if condition == nil {
            break linear_sweep
          }

        case .jp(.immediate16, let condition):
          let jumpTo = instruction.immediate16!
          if !visitedAddresses.contains(Int(LR35902.romAddress(for: jumpTo, in: bank))) {
            jumpAddresses.append(BankedAddress(bank: bank, address: jumpTo))
          }
          disassembly.registerTransferOfControl(to: jumpTo, in: bank, from: pc, kind: .jp)

          if condition == nil {
            break linear_sweep
          }

        case .call(.immediate16, _):
          let jumpTo = instruction.immediate16!
          if !visitedAddresses.contains(Int(LR35902.romAddress(for: jumpTo, in: bank))) {
            jumpAddresses.append(BankedAddress(bank: bank, address: jumpTo))
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
}
