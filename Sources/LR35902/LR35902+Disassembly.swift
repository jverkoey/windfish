import Foundation

extension LR35902 {

  /// A class that owns and manages disassembly information for a given ROM.
  public class Disassembly {

    let cpu: LR35902
    public init(rom: Data) {
      cpu = LR35902(rom: rom)

      // Restart addresses
      let numberOfRestartAddresses = 8
      let restartSize = 8
      let rstAddresses = (0..<numberOfRestartAddresses)
        .map { UInt16($0 * restartSize)..<UInt16($0 * restartSize + restartSize) }
      rstAddresses.forEach {
        setLabel(at: $0.lowerBound, in: 0x00, named: "RST_\($0.lowerBound.hexString)")
        disassemble(range: $0, inBank: 0)
      }

      setLabel(at: 0x0040, in: 0x00, named: "VBlankInterrupt")
      disassemble(range: 0x0040..<0x0048, inBank: 0)

      setLabel(at: 0x0048, in: 0x00, named: "LCDCInterrupt")
      disassemble(range: 0x0048..<0x0050, inBank: 0)

      setLabel(at: 0x0050, in: 0x00, named: "TimerOverflowInterrupt")
      disassemble(range: 0x0050..<0x0058, inBank: 0)

      setLabel(at: 0x0058, in: 0x00, named: "SerialTransferCompleteInterrupt")
      disassemble(range: 0x0058..<0x0060, inBank: 0)

      setLabel(at: 0x0060, in: 0x00, named: "JoypadTransitionInterrupt")
      disassemble(range: 0x0060..<0x0068, inBank: 0)

      setLabel(at: 0x0100, in: 0x00, named: "Boot")
      disassemble(range: 0x0100..<0x104, inBank: 0)

      setLabel(at: 0x0104, in: 0x00, named: "HeaderLogo")
      setData(at: 0x0104..<0x0134, in: 0x00)

      setLabel(at: 0x0134, in: 0x00, named: "HeaderTitle")
      setText(at: 0x0134..<0x0143, in: 0x00)

      setLabel(at: 0x0143, in: 0x00, named: "HeaderIsColorGB")
      setData(at: 0x0143, in: 0x00)

      setLabel(at: 0x0144, in: 0x00, named: "HeaderNewLicenseeCode")
      setData(at: 0x0144..<0x0146, in: 0x00)

      setLabel(at: 0x0146, in: 0x00, named: "HeaderSGBFlag")
      setData(at: 0x0146, in: 0x00)

      setLabel(at: 0x0147, in: 0x00, named: "HeaderCartridgeType")
      setData(at: 0x0147, in: 0x00)

      setLabel(at: 0x0148, in: 0x00, named: "HeaderROMSize")
      setData(at: 0x0148, in: 0x00)

      setLabel(at: 0x0149, in: 0x00, named: "HeaderRAMSize")
      setData(at: 0x0149, in: 0x00)

      setLabel(at: 0x014A, in: 0x00, named: "HeaderDestinationCode")
      setData(at: 0x014A, in: 0x00)

      setLabel(at: 0x014B, in: 0x00, named: "HeaderOldLicenseeCode")
      setData(at: 0x014B, in: 0x00)

      setLabel(at: 0x014C, in: 0x00, named: "HeaderMaskROMVersion")
      setData(at: 0x014C, in: 0x00)

      setLabel(at: 0x014D, in: 0x00, named: "HeaderComplementCheck")
      setData(at: 0x014D, in: 0x00)

      setLabel(at: 0x014E, in: 0x00, named: "HeaderGlobalChecksum")
      setData(at: 0x014E..<0x0150, in: 0x00)

      createGlobal(at: 0xA000, named: "CARTRAM")
      createGlobal(at: 0xFF47, named: "rBGP")
      createGlobal(at: 0xFF48, named: "rOBP0")
      createGlobal(at: 0xFF49, named: "rOBP1")
    }

    // MARK: - Transfers of control

    public struct TransferOfControl: Hashable {
      public enum Kind {
        case jr, jp, call
      }
      public let sourceAddress: UInt16
      public let kind: Kind
    }
    public func transfersOfControl(at pc: UInt16, in bank: UInt8) -> Set<TransferOfControl>? {
      return transfers[romAddress(for: pc, in: bank)]
    }

    func registerTransferOfControl(to pc: UInt16, in bank: UInt8, from fromPc: UInt16, kind: TransferOfControl.Kind) {
      let index = romAddress(for: pc, in: bank)
      transfers[index, default: Set()]
        .insert(TransferOfControl(sourceAddress: fromPc, kind: kind))
      if labels[index] == nil
        // Don't create a label in the middle of an instruction.
        && (!code.contains(Int(index)) || instruction(at: pc, in: bank) != nil) {
        labels[index] = RGBDSAssembly.defaultLabel(at: pc, in: bank)
      }
    }
    private var transfers: [UInt32: Set<TransferOfControl>] = [:]

    // MARK: - Instructions

    public func instruction(at pc: UInt16, in bank: UInt8) -> Instruction? {
      return instructionMap[romAddress(for: pc, in: bank)]
    }

    func register(instruction: Instruction, at pc: UInt16, in bank: UInt8) {
      let address = romAddress(for: pc, in: bank)
      instructionMap[address] = instruction

      code.insert(integersIn: Int(address)..<(Int(address) + Int(LR35902.instructionWidths[instruction.spec]!)))
    }
    private var instructionMap: [UInt32: Instruction] = [:]

    // MARK: - Data segments

    public func setData(at address: UInt16, in bank: UInt8) {
      data.insert(Int(romAddress(for: address, in: bank)))
    }
    public func setData(at range: Range<UInt16>, in bank: UInt8) {
      let lowerBound = romAddress(for: range.lowerBound, in: bank)
      let upperBound = romAddress(for: range.upperBound, in: bank)
      data.insert(integersIn: Int(lowerBound)..<Int(upperBound))
    }

    // MARK: - Text segments

    public func setText(at range: Range<UInt16>, in bank: UInt8) {
      let lowerBound = romAddress(for: range.lowerBound, in: bank)
      let upperBound = romAddress(for: range.upperBound, in: bank)
      text.insert(integersIn: Int(lowerBound)..<Int(upperBound))
    }

    // MARK: - Bank changes

    public func bankChange(at pc: UInt16, in bank: UInt8) -> UInt8? {
      return bankChanges[romAddress(for: pc, in: bank)]
    }

    func register(bankChange: UInt8, at pc: UInt16, in bank: UInt8) {
      bankChanges[romAddress(for: pc, in: bank)] = bankChange
    }
    private var bankChanges: [UInt32: UInt8] = [:]

    // MARK: - Regions

    public enum ByteType {
      case unknown
      case code
      case data
      case text
    }
    public func type(of address: UInt16, in bank: UInt8) -> ByteType {
      let index = Int(romAddress(for: address, in: bank))
      if code.contains(index) {
        return .code
      } else if data.contains(index) {
        return .data
      } else if text.contains(index) {
        return .text
      } else {
        return .unknown
      }
    }

    private var code = IndexSet()
    private var data = IndexSet()
    private var text = IndexSet()

    // MARK: - Functions

    public func function(startingAt pc: UInt16, in bank: UInt8) -> String? {
      return functions[romAddress(for: pc, in: bank)]
    }

    public func defineFunction(startingAt pc: UInt16, in bank: UInt8, named name: String) {
      setLabel(at: pc, in: bank, named: name)

      functions[romAddress(for: pc, in: bank)] = name
    }
    private var functions: [UInt32: String] = [:]

    // MARK: - Labels

    public func label(at pc: UInt16, in bank: UInt8) -> String? {
      return labels[romAddress(for: pc, in: bank)]
    }

    public func setLabel(at pc: UInt16, in bank: UInt8, named name: String) {
      labels[romAddress(for: pc, in: bank)] = name
    }
    private var labels: [UInt32: String] = [:]

    // MARK: - Globals

    public func createGlobal(at address: UInt16, named name: String) {
      globals[address] = name
    }
    var globals: [UInt16: String] = [:]

    // MARK: - Comments

    public func preComment(at address: UInt16, in bank: UInt8) -> String? {
      return preComments[romAddress(for: address, in: bank)]
    }
    public func setPreComment(at address: UInt16, in bank: UInt8, text: String) {
      preComments[romAddress(for: address, in: bank)] = text
    }
    private var preComments: [UInt32: String] = [:]

    // MARK: - Macros

    public enum MacroLine: Hashable {
      case any(InstructionSpec)
      case instruction(Instruction)
    }
    public func defineMacro(named name: String,
                            instructions: [MacroLine],
                            code: [InstructionSpec],
                            validArgumentValues: [Int: IndexSet]) {
      let leaf = instructions.reduce(macroTree, { node, spec in
        let child = node.children[spec, default: MacroNode()]
        node.children[spec] = child
        return child
      })
      leaf.macro = name
      leaf.code = code
      leaf.macroLines = instructions
      leaf.validArgumentValues = validArgumentValues
    }

    public class MacroNode {
      var children: [MacroLine: MacroNode] = [:]
      var macro: String?
      var code: [InstructionSpec]?
      var macroLines: [MacroLine]?
      var validArgumentValues: [Int: IndexSet]?
      var hasWritten = false
    }
    public let macroTree = MacroNode()

    public func disassemble(range: Range<UInt16>, inBank bankInitial: UInt8) {
      var jumpAddresses: [BankedAddress] = []
      jumpAddresses.append(BankedAddress(bank: bankInitial, address: range.lowerBound))

      var visitedAddresses = IndexSet()
      var isFirst = true

      while !jumpAddresses.isEmpty {
        let address = jumpAddresses.removeFirst()
        cpu.bank = address.bank
        cpu.pc = address.address

        var previousInstruction: Instruction? = nil
        linear_sweep: while (!isFirst && ((cpu.bank == 0 && cpu.pc < 0x4000) || (cpu.bank != 0 && cpu.pc < 0x8000))) || cpu.pc < range.upperBound {
          let byte = Int(cpu[cpu.pc, cpu.bank])

          var spec = LR35902.instructionTable[byte]

          var opcodeWidth: UInt16
          var operandWidth: UInt16
          switch spec {
          case .invalid:
            cpu.pc += 1
            continue

          case .cb:
            let byteCB = Int(cpu[cpu.pc + 1, cpu.bank])
            let cbInstruction = LR35902.instructionTableCB[byteCB]
            if case .invalid = spec {
              cpu.pc += 2
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
            instruction = Instruction(spec: spec, immediate8: cpu[cpu.pc + opcodeWidth, cpu.bank])
          case 2:
            let low = UInt16(cpu[cpu.pc + opcodeWidth, cpu.bank])
            let high = UInt16(cpu[cpu.pc + opcodeWidth + 1, cpu.bank]) << 8
            let immediate16 = high | low
            instruction = Instruction(spec: spec, immediate16: immediate16)
          default:
            instruction = Instruction(spec: spec)
          }

          if case .stop = spec {
            // STOP must be followed by 0
            if instruction.immediate8 != 0 {
              cpu.pc += 1
              continue
            }
          }

          register(instruction: instruction, at: cpu.pc, in: cpu.bank)

          let nextPc = cpu.pc + instructionWidth

          let lowerBound = Int(LR35902.romAddress(for: cpu.pc, in: cpu.bank))
          visitedAddresses.insert(integersIn: lowerBound..<(lowerBound + Int(instructionWidth)))

          switch spec {
          case .ld(.immediate16address, .a):
            if (0x2000..<0x4000).contains(instruction.immediate16!),
              let previousInstruction = previousInstruction,
              case .ld(.a, .immediate8) = previousInstruction.spec {
              register(bankChange: previousInstruction.immediate8!, at: cpu.pc, in: cpu.bank)

              cpu.bank = previousInstruction.immediate8!
            }
            break
          case .jr(.immediate8signed, let condition):
            let relativeJumpAmount = Int8(bitPattern: instruction.immediate8!)
            let jumpTo = nextPc.advanced(by: Int(relativeJumpAmount))
            if !visitedAddresses.contains(Int(LR35902.romAddress(for: jumpTo, in: cpu.bank))) {
              jumpAddresses.append(BankedAddress(bank: cpu.bank, address: jumpTo))
            }
            registerTransferOfControl(to: jumpTo, in: cpu.bank, from: cpu.pc, kind: .jr)

            if condition == nil {
              break linear_sweep
            }

          case .jp(.immediate16, let condition):
            let jumpTo = instruction.immediate16!
            if !visitedAddresses.contains(Int(LR35902.romAddress(for: jumpTo, in: cpu.bank))) {
              jumpAddresses.append(BankedAddress(bank: cpu.bank, address: jumpTo))
            }
            registerTransferOfControl(to: jumpTo, in: cpu.bank, from: cpu.pc, kind: .jp)

            if condition == nil {
              break linear_sweep
            }

          case .call(.immediate16, _):
            let jumpTo = instruction.immediate16!
            if !visitedAddresses.contains(Int(LR35902.romAddress(for: jumpTo, in: cpu.bank))) {
              jumpAddresses.append(BankedAddress(bank: cpu.bank, address: jumpTo))
            }
            registerTransferOfControl(to: jumpTo, in: cpu.bank, from: cpu.pc, kind: .call)

          case .jp(_, nil), .ret:
            break linear_sweep

          default:
            break
          }

          cpu.pc = nextPc
          previousInstruction = instruction
        }

        isFirst = false
      }
    }

  }
}
