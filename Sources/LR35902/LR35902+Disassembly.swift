import Foundation

extension LR35902 {

  /// A class that owns and manages disassembly information for a given ROM.
  public class Disassembly {

    let cpu: LR35902
    public init(rom: Data) {
      cpu = LR35902(rom: rom)
    }

    public func disassembleAsGameboyCartridge() {
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

    struct TransferOfControl: Hashable {
      let sourceAddress: UInt16
      let sourceInstructionSpec: InstructionSpec
    }
    func transfersOfControl(at pc: UInt16, in bank: UInt8) -> Set<TransferOfControl>? {
      return transfers[romAddress(for: pc, in: bank)]
    }

    func registerTransferOfControl(to pc: UInt16, in bank: UInt8, from fromPc: UInt16, instructionSpec: InstructionSpec) {
      let index = romAddress(for: pc, in: bank)
      let transfer = TransferOfControl(sourceAddress: fromPc, sourceInstructionSpec: instructionSpec)
      transfers[index, default: Set()].insert(transfer)

      // Create a label if one doesn't exist.
      if labels[index] == nil
        // Don't create a label in the middle of an instruction.
        && (!code.contains(Int(index)) || instruction(at: pc, in: bank) != nil) {
        labels[index] = RGBDSAssembly.defaultLabel(at: pc, in: bank)
      }
    }
    private var transfers: [UInt32: Set<TransferOfControl>] = [:]

    // MARK: - Instructions

    func instruction(at pc: UInt16, in bank: UInt8) -> Instruction? {
      return instructionMap[romAddress(for: pc, in: bank)]
    }

    func register(instruction: Instruction, at pc: UInt16, in bank: UInt8) {
      let address = romAddress(for: pc, in: bank)

      // Avoid overlapping instructions.
      if code.contains(Int(address)) && instructionMap[address] == nil {
        return
      }

      instructionMap[address] = instruction

      code.insert(integersIn: Int(address)..<(Int(address) + Int(LR35902.instructionWidths[instruction.spec]!)))
    }
    var instructionMap: [UInt32: Instruction] = [:]

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
    public func scope(at pc: UInt16, in bank: UInt8) -> Set<String> {
      let address = romAddress(for: pc, in: bank)
      let intersectingScopes = scopes.filter { iterator in
        iterator.value.contains(Int(address))
      }
      return Set(intersectingScopes.keys)
    }
    public func contiguousScope(at pc: UInt16, in bank: UInt8) -> String? {
      return contiguousScopes[romAddress(for: pc, in: bank)]
    }

    public func defineFunction(startingAt pc: UInt16, in bank: UInt8, named name: String) {
      setLabel(at: pc, in: bank, named: name)
      functions[romAddress(for: pc, in: bank)] = name

      let upperBound: UInt16 = (bank == 0) ? 0x4000 : 0x8000
      disassemble(range: pc..<upperBound, inBank: bank, function: name)
    }
    private var functions: [UInt32: String] = [:]
    private var contiguousScopes: [UInt32: String] = [:]
    private var scopes: [String: IndexSet] = [:]

    // MARK: - Labels

    public func label(at pc: UInt16, in bank: UInt8) -> String? {
      let index = romAddress(for: pc, in: bank)
      // Don't return labels that point to the middle of instructions.
      if code.contains(Int(index)) && instructionMap[index] == nil {
        return nil
      }
      return labels[index]
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

    private struct DisassemblyIntent: Hashable {
      let bank: UInt8
      let address: UInt16
    }

    public func disassemble(range: Range<UInt16>, inBank bankInitial: UInt8, function: String? = nil) {
      var visitedAddresses = IndexSet()

      let runQueue = RunQueue()
      let firstRun = Run(from: range.lowerBound, inBank: bankInitial, upTo: range.upperBound, function: function)
      runQueue.add(firstRun)

      let queueRun: (Run, UInt16, UInt16, UInt8, LR35902.Instruction) -> Void = { fromRun, fromAddress, toAddress, bank, instruction in
        let run = Run(from: toAddress, inBank: bank)
        run.invocationInstruction = instruction
        run.invocationAddress = fromAddress
        run.parent = fromRun
        runQueue.add(run)

        fromRun.children.append(run)

        self.registerTransferOfControl(to: toAddress, in: bank, from: fromAddress, instructionSpec: instruction.spec)
      }

      while !runQueue.isEmpty {
        let run = runQueue.dequeue()

        if visitedAddresses.contains(Int(LR35902.romAddress(for: run.startAddress, in: run.bank))) {
          // We've already visited this instruction, so we can skip it.
          continue
        }

        // Initialize the CPU
        cpu.bank = run.bank
        cpu.pc = run.startAddress

        let advance: (UInt16) -> Void = { amount in
          let lowerBound = LR35902.romAddress(for: self.cpu.pc, in: self.cpu.bank)
          let instructionRange = Int(lowerBound)..<Int(lowerBound + UInt32(amount))
          run.visitedRange = UInt32(run.startAddress)..<UInt32(instructionRange.upperBound)

          visitedAddresses.insert(integersIn: instructionRange)

          self.cpu.pc += amount
        }

        var previousInstruction: Instruction? = nil
        linear_sweep: while !run.hasReachedEnd(with: cpu) {
          let byte = Int(cpu[cpu.pc, cpu.bank])

          var spec = LR35902.instructionTable[byte]

          var opcodeWidth: UInt16
          var operandWidth: UInt16
          switch spec {
          case .invalid:
            advance(1)
            continue

          case .cb:
            let byteCB = Int(cpu[cpu.pc + 1, cpu.bank])
            let cbInstruction = LR35902.instructionTableCB[byteCB]
            if case .invalid = spec {
              advance(2)
              continue
            }
            spec = cbInstruction

            opcodeWidth = 2
            operandWidth = operandWidthsCB[byteCB]

          default:
            opcodeWidth = 1
            operandWidth = operandWidths[byte]
            break
          }

          let instructionAddress = cpu.pc
          let instructionBank = cpu.bank
          let instructionWidth = opcodeWidth + operandWidth
          let instruction: Instruction
          switch operandWidth {
          case 1:
            instruction = Instruction(spec: spec, imm8: cpu[instructionAddress + opcodeWidth, instructionBank])
          case 2:
            let low = UInt16(cpu[instructionAddress + opcodeWidth, instructionBank])
            let high = UInt16(cpu[instructionAddress + opcodeWidth + 1, instructionBank]) << 8
            let immediate16 = high | low
            instruction = Instruction(spec: spec, imm16: immediate16)
          default:
            instruction = Instruction(spec: spec)
          }

          // STOP must be followed by 0
          if case .stop = spec, instruction.imm8 != 0 {
            advance(1)
            continue
          }

          register(instruction: instruction, at: instructionAddress, in: instructionBank)
          advance(instructionWidth)

          switch spec {
          case .ld(.imm16addr, .a):
            if (0x2000..<0x4000).contains(instruction.imm16!),
              let previousInstruction = previousInstruction,
              case .ld(.a, .imm8) = previousInstruction.spec {
              register(bankChange: previousInstruction.imm8!, at: instructionAddress, in: instructionBank)

              cpu.bank = previousInstruction.imm8!
            }

          case .jr(let condition, .simm8):
            let relativeJumpAmount = Int8(bitPattern: instruction.imm8!)
            let jumpTo = cpu.pc.advanced(by: Int(relativeJumpAmount))
            queueRun(run, instructionAddress, jumpTo, instructionBank, instruction)

            // An unconditional jr is the end of the run.
            if condition == nil {
              break linear_sweep
            }

          case .jp(let condition, .imm16):
            let jumpTo = instruction.imm16!
            queueRun(run, instructionAddress, jumpTo, instructionBank, instruction)

            // An unconditional jp is the end of the run.
            if condition == nil {
              break linear_sweep
            }

          case .call(_, .imm16):
            let jumpTo = instruction.imm16!
            queueRun(run, instructionAddress, jumpTo, instructionBank, instruction)

          case .jp(_, nil), .ret, .reti:
            break linear_sweep

          default:
            break
          }

          previousInstruction = instruction
        }
      }

      // Compute scope and rewrite function labels if we're a function.

      for runGroup in firstRun.runGroups() {
        // Calculate scope.
        var runScope = IndexSet()
        runGroup.forEach { run in
          if let visitedRange = run.visitedRange {
            runScope.insert(integersIn: Int(visitedRange.lowerBound)..<Int(visitedRange.upperBound))
          }
        }

        // Nothing to do for empty runs.
        if runScope.isEmpty {
          continue
        }

        // If the scope has a name, then map the scope and labels to that name.
        let entryRun = runGroup.first!
        let runStartAddress = LR35902.romAddress(for: entryRun.startAddress, in: entryRun.bank)
        if let runGroupName = labels[runStartAddress] {
          scopes[runGroupName, default: IndexSet()].formUnion(runScope)

          // Get the first contiguous block of scope.
          if let runScope = runScope.rangeView.first(where: { $0.lowerBound == runStartAddress }) {
            for address in runScope {
              contiguousScopes[UInt32(address)] = runGroupName
            }

            var firstReturnIndex: UInt32? = nil

            runScope.dropFirst().forEach {
              let index = UInt32($0)
              guard labels[index] != nil else {
                return
              }
              if case .ret = instructionMap[index]?.spec {
                if let firstReturnIndex = firstReturnIndex {
                  labels[index] = "\(runGroupName).return_\(UInt16(index % LR35902.bankSize).hexString)"
                  labels[firstReturnIndex] = "\(runGroupName).return_\(UInt16(firstReturnIndex % LR35902.bankSize).hexString)"
                } else {
                  labels[index] = "\(runGroupName).return"
                  firstReturnIndex = index
                }
              } else {
                let bank = UInt8(index / LR35902.bankSize)
                let address = index % LR35902.bankSize + ((bank > 0) ? UInt32(0x4000) : UInt32(0x0000))
                labels[index] = "\(runGroupName).fn_\(bank.hexString)_\(UInt16(address).hexString)"
              }
            }
          }
        }
      }
    }
  }
}
