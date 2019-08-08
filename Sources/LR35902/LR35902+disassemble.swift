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
        let byte = self[pc, bank]
        var opcodeWidth: UInt16 = 1
        guard var spec = LR35902.opcodeDescription[byte] else {
          pc += opcodeWidth
          continue
        }
        switch spec {
        case .stop:
          // The next byte needs to be 00.
          let nextByte = self[pc + 1, bank]
          if nextByte != 0 {
            pc += opcodeWidth
            continue
          } else {
            // Stop is technically a two-byte instruction.
            opcodeWidth += 1
          }

        case .invalid:
          pc += opcodeWidth
          continue

        case .cb:
          let byte = self[pc + 1, bank]
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
        default:
          break
        }

        let instructionWidth = opcodeWidth + spec.operandWidth
        let instruction: Instruction
        switch spec.operandWidth {
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
