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
    public func scope(at pc: UInt16, in bank: UInt8) -> String? {
      return scopes[romAddress(for: pc, in: bank)]
    }

    public func defineFunction(startingAt pc: UInt16, in bank: UInt8, named name: String) {
      setLabel(at: pc, in: bank, named: name)
      functions[romAddress(for: pc, in: bank)] = name

      let upperBound: UInt16 = (bank == 0) ? 0x4000 : 0x8000
      let functionScope = disassemble(range: pc..<upperBound, inBank: bank, function: name).rangeView.first!

      for address in functionScope {
        scopes[UInt32(address)] = name
      }
    }
    private var functions: [UInt32: String] = [:]
    private var scopes: [UInt32: String] = [:]

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

    private struct DisassemblyIntent: Hashable {
      let bank: UInt8
      let address: UInt16
    }

    private class Run {
      let startAddress: UInt16
      let endAddress: UInt16?
      let bank: UInt8
      let function: String?
      init(from startAddress: UInt16, inBank bank: UInt8, upTo endAddress: UInt16? = nil, function: String? = nil) {
        self.startAddress = startAddress
        self.endAddress = endAddress
        self.bank = bank
        self.function = function
      }

      var visitedRange: Range<UInt32>?

      var sourceRun: Run? = nil
      var sourceInstruction: LR35902.Instruction?
      var sourceAddress: UInt16?
    }

    @discardableResult
    public func disassemble(range: Range<UInt16>, inBank bankInitial: UInt8, function: String? = nil) -> IndexSet {
      var allVisitedAddresses = IndexSet()
      var isFirst = true

      var runQueue: [Run] = [
        Run(from: range.lowerBound, inBank: bankInitial, upTo: range.upperBound, function: function)
      ]
      var runs: [Run] = []

      let pcIsValidForBank: () -> Bool = {
        let pc = self.cpu.pc
        let bank = self.cpu.bank
        return (bank == 0 && pc < 0x4000) || (bank != 0 && pc < 0x8000)
      }

      let queueRun: (Run, UInt16, UInt16, UInt8, LR35902.Instruction) -> Void = { fromRun, fromAddress, toAddress, bank, instruction in
        if !allVisitedAddresses.contains(Int(LR35902.romAddress(for: toAddress, in: bank))) {
          let run = Run(from: toAddress, inBank: bank)
          run.sourceInstruction = instruction
          run.sourceAddress = fromAddress
          run.sourceRun = fromRun
          runQueue.append(run)
        }
        self.registerTransferOfControl(to: toAddress, in: bank, from: fromAddress, instructionSpec: instruction.spec)
      }

      while !runQueue.isEmpty {
        let run = runQueue.removeFirst()
        runs.append(run)

        if allVisitedAddresses.contains(Int(LR35902.romAddress(for: run.startAddress, in: run.bank))) {
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

          allVisitedAddresses.insert(integersIn: instructionRange)

          self.cpu.pc += amount
        }

        var previousInstruction: Instruction? = nil
        linear_sweep: while (isFirst && cpu.pc < range.upperBound) || (!isFirst && pcIsValidForBank()) {
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
            operandWidth = LR35902.operandWidthsCB[byteCB]

          default:
            opcodeWidth = 1
            operandWidth = LR35902.operandWidths[byte]
            break
          }

          let instructionAddress = cpu.pc
          let instructionBank = cpu.bank
          let instructionWidth = opcodeWidth + operandWidth
          let instruction: Instruction
          switch operandWidth {
          case 1:
            instruction = Instruction(spec: spec, immediate8: cpu[instructionAddress + opcodeWidth, instructionBank])
          case 2:
            let low = UInt16(cpu[instructionAddress + opcodeWidth, instructionBank])
            let high = UInt16(cpu[instructionAddress + opcodeWidth + 1, instructionBank]) << 8
            let immediate16 = high | low
            instruction = Instruction(spec: spec, immediate16: immediate16)
          default:
            instruction = Instruction(spec: spec)
          }

          // STOP must be followed by 0
          if case .stop = spec, instruction.immediate8 != 0 {
            advance(1)
            continue
          }

          register(instruction: instruction, at: instructionAddress, in: instructionBank)
          advance(instructionWidth)

          switch spec {
          case .ld(.immediate16address, .a):
            if (0x2000..<0x4000).contains(instruction.immediate16!),
              let previousInstruction = previousInstruction,
              case .ld(.a, .immediate8) = previousInstruction.spec {
              register(bankChange: previousInstruction.immediate8!, at: instructionAddress, in: instructionBank)

              cpu.bank = previousInstruction.immediate8!
            }

          case .jr(.immediate8signed, let condition):
            let relativeJumpAmount = Int8(bitPattern: instruction.immediate8!)
            let jumpTo = cpu.pc.advanced(by: Int(relativeJumpAmount))
            queueRun(run, instructionAddress, jumpTo, instructionBank, instruction)

            // An unconditional jr is the end of the run.
            if condition == nil {
              break linear_sweep
            }

          case .jp(.immediate16, let condition):
            let jumpTo = instruction.immediate16!
            queueRun(run, instructionAddress, jumpTo, instructionBank, instruction)

            // An unconditional jp is the end of the run.
            if condition == nil {
              break linear_sweep
            }

          case .call(.immediate16, _):
            let jumpTo = instruction.immediate16!
            queueRun(run, instructionAddress, jumpTo, instructionBank, instruction)

          case .jp(_, nil), .ret:
            break linear_sweep

          default:
            break
          }

          previousInstruction = instruction
        }

        if isFirst {
          isFirst = false
        }
      }

      // Compute scope and rewrite function labels if we're a function.

      let functionRuns = runs.filter { run in
        // Always include the initial run.
        guard let sourceInstruction = run.sourceInstruction else {
          return true
        }

        // Ignore empty runs.
        guard let visitedRange = run.visitedRange,
              !visitedRange.isEmpty else {
          return false
        }

        // Filter out calls.
        if case .call = sourceInstruction.spec {
          return false
        }

        // Filter out runs spawned from calls.
        // TODO: This would be more efficient if we could traverse the run tree top-down rather than bottom-up.
        // Consider adding a "child runs" property to Run and allowing the Run structure to maintain the hierarchy
        // instead.
        var runIterator = run
        while let runAncestor = runIterator.sourceRun {
          if let sourceInstruction = runAncestor.sourceInstruction,
            case .call = sourceInstruction.spec {
            return false
          }
          runIterator = runAncestor
        }

        // Keep everything else.
        return true
      }

      var functionScope = IndexSet()
      functionRuns.forEach { run in
        functionScope.insert(integersIn: Int(run.visitedRange!.lowerBound)..<Int(run.visitedRange!.upperBound))
      }

      if let function = function {
        functionRuns.forEach { run in
          let labelAddresses = run.visitedRange!.dropLast().filter { $0 != range.lowerBound && labels[$0] != nil }
          labelAddresses.forEach {
            let bank = UInt8($0 / LR35902.bankSize)
            let address = $0 % LR35902.bankSize + ((bank > 0) ? UInt32(0x4000) : UInt32(0x0000))
            labels[$0] = "\(function).fn_\(bank.hexString)_\(UInt16(address).hexString)"
          }
        }

        let runsWithReturns = functionRuns.filter {
          if case .ret = instructionMap[$0.visitedRange!.upperBound - 1]?.spec {
            return true
          } else {
            return false
          }
        }
        runsWithReturns.forEach { run in
          let returnLabelAddress = run.visitedRange!.upperBound - 1
          if labels[returnLabelAddress] != nil {
            labels[returnLabelAddress] = "\(function).return"
          }
        }
      }

      return functionScope
    }
  }
}
