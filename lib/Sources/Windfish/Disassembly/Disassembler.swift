import Foundation

import RGBDS

extension LR35902.Instruction.Spec: InstructionSpecDisassemblyInfo {
  var category: InstructionCategory? {
    switch self {
    case .call: return .call
    case .ret, .reti: return .ret
    default: return nil
    }
  }
}

protocol DisassemblerContext: class {
  func allPotentialCode() -> Set<Range<Cartridge.Location>>

  func preComment(at location: Cartridge.Location) -> String?

  func datatypeExists(named name: String) -> Bool
  func datatype(named name: String) -> Disassembler.Configuration.Datatype?
  func allDatatypes() -> [String: Disassembler.Configuration.Datatype]

  func shouldTerminateLinearSweep(at location: Cartridge.Location) -> Bool

  func global(at address: LR35902.Address) -> Disassembler.Configuration.Global?
  func allGlobals() -> [LR35902.Address: Disassembler.Configuration.Global]

  func allScripts() -> [String: Disassembler.Configuration.Script]

  func allMappedCharacters() -> [UInt8: String]

  func macroTreeRoot() -> Disassembler.Configuration.MacroNode

  func label(at location: Cartridge.Location) -> String?
}

/// A class that owns and manages disassembly information for a given ROM.
public final class Disassembler {

  public final class Configuration: DisassemblerContext {
    /** Ranges of executable regions that should be disassembled. */
    var executableRegions = Set<Range<Cartridge.Location>>()

    /** Comments that should be placed immediately before the given location. */
    var preComments: [Cartridge.Location: String] = [:]

    /** Registered data types. */
    var dataTypes: [String: Datatype] = [:]

    /** Named regions of memory that can be read as data. */
    var globals: [LR35902.Address: Global] = [:]

    /** The names of specific locations in the cartridge. */
    var labelNames: [Cartridge.Location: String] = [:]

    /** When a soft terminator is encountered during linear sweep the sweep will immediately end. */
    var softTerminators: [Cartridge.Location: Bool] = [:]

    /** Scripts that should be executed alongside the disassembler. */
    var scripts: [String: Script] = [:]

    /** Character codes mapped to strings. */
    var characterMap: [UInt8: String] = [:]

    /**
     Macros are stored in a tree, where each edge is a representation of an instruction and the leaf nodes are the macro
     implementation.
     */
    let macroTree = MacroNode()
  }

  public let mutableConfiguration = Configuration()
  var configuration: DisassemblerContext {
    return mutableConfiguration
  }

  let memory: DisassemblerMemory
  let cartridgeData: Data
  let cartridgeSize: Cartridge.Length
  public let numberOfBanks: Cartridge.Bank
  public init(data: Data) {
    self.cartridgeData = data
    self.memory = DisassemblerMemory(data: data)
    self.cartridgeSize = Cartridge.Length(data.count)
    self.numberOfBanks = Cartridge.Bank(truncatingIfNeeded: (cartridgeSize + 0x4000 - 1) / 0x4000)
  }

  /** Returns true if the program counter is pointing to addressable memory. */
  func pcIsValid(pc: LR35902.Address, bank: Cartridge.Bank) -> Bool {
    return pc < 0x8000 && Cartridge.Location(address: pc, bank: bank).index < cartridgeSize
  }

  // MARK: - Pre-disassembly hints and configurations

  /** Hints to the disassembler that a given location should be represented by a specific data type. */
  var typeAtLocation: [Cartridge.Location: String] = [:]

  // MARK: - Disassembly results

  // MARK: Code

  /** All locations that represent code. */
  var code = IndexSet()

  /** Locations that can transfer control (jp/call) to a specific location. */
  var transfers: [Cartridge.Location: Set<Cartridge.Location>] = [:]

  /** Which instruction exists at a specific location. */
  var instructionMap: [Cartridge.Location: LR35902.Instruction] = [:]

  /** Each bank tracks ranges of code that represent contiguous scopes of instructions. */
  var contiguousScopes: [Cartridge.Bank: Set<Range<Cartridge.Location>>] = [:]

  /**
   Label types at specific locations.

   There does not always need to be a corresponding name set in the labelNames dictionary.
   */
  var labelTypes: [Cartridge.Location: LabelType] = [:]

  /** Bank changes that occur at a specific location. */
  var bankChanges: [Cartridge.Location: Cartridge.Bank] = [:]

  // MARK: Data

  /** All locations that represent data. */
  var data = IndexSet()

  /**
   We never want to show labels in the middle of a contiguous block of data, so when registering data regions we remove
   the first byte of the data region and then register that range to this index set. When determining whether a label
   can be shown at a given location we consult this "swiss cheese" index set rather than the data index set.
   */
  var dataBlocks = IndexSet()

  /** The format of the data at specific locations. */
  var dataFormats: [DataFormat: IndexSet] = [:]

  // MARK: Text

  /** All locations that represent text. */
  var text = IndexSet()

  /** The maximum length of a line of text within a given range. */
  var textLengths: [Range<Cartridge.Location>: Int] = [:]

  func effectiveBank(at pc: LR35902.Address, in bank: Cartridge.Bank) -> Cartridge.Bank {
    if pc < 0x4000 {
      return 1
    }
    return bank
  }

  public func willStart() {
    // Script functions
    let getROMData: @convention(block) (Int, Int, Int) -> [UInt8] = { [weak self] bank, startAddress, endAddress in
      guard let self = self else {
        return []
      }
      let startLocation = Cartridge.Location(address: startAddress, bank: bank)
      let endLocation = Cartridge.Location(address: endAddress, bank: bank)
      return [UInt8](self.cartridgeData[startLocation.index..<endLocation.index])
    }
    let registerText: @convention(block) (Int, Int, Int, Int) -> Void = { [weak self] bank, startAddress, endAddress, lineLength in
      guard let self = self else {
        return
      }
      self.registerText(at: Cartridge.Location(address: startAddress, bank: bank)..<Cartridge.Location(address: endAddress, bank: bank),
                        lineLength: lineLength)
    }
    let registerData: @convention(block) (Int, Int, Int) -> Void = { [weak self] bank, startAddress, endAddress in
      guard let self = self else {
        return
      }
      self.registerData(
        at: Cartridge.Location(address: startAddress, bank: bank)..<Cartridge.Location(address: endAddress, bank: bank)
      )
    }
    let registerJumpTable: @convention(block) (Int, Int, Int) -> Void = { [weak self] bank, startAddress, endAddress in
      guard let self = self else {
        return
      }
      self.registerData(
        at: Cartridge.Location(address: startAddress, bank: bank)..<Cartridge.Location(address: endAddress, bank: bank),
        format: .jumpTable
      )
    }
    let registerTransferOfControl: @convention(block) (Int, Int, Int, Int, Int) -> Void = { [weak self] toBank, toAddress, fromBank, fromAddress, opcode in
      guard let self = self else {
        return
      }
      self.registerTransferOfControl(
        to: Cartridge.Location(address: toAddress, bank: toBank),
        from: Cartridge.Location(address: fromAddress, bank: fromBank),
        spec: LR35902.InstructionSet.table[opcode]
      )
    }
    let registerFunction: @convention(block) (Int, Int, String) -> Void = { [weak self] bank, address, name in
      guard let self = self else {
        return
      }
      self.mutableConfiguration.registerFunction(startingAt: Cartridge.Location(address: address, bank: bank), named: name)
    }
    let registerBankChange: @convention(block) (Int, Int, Int) -> Void = { [weak self] _desiredBank, address, bank in
      guard let self = self else {
        return
      }
      let desiredBank = Cartridge.Bank(truncatingIfNeeded: _desiredBank)
      let location = Cartridge.Location(address: LR35902.Address(truncatingIfNeeded: address),
                                        bank: Cartridge.Bank(truncatingIfNeeded: bank))
      self.registerBankChange(to: max(1, desiredBank), at: location)
    }
    let hex16: @convention(block) (Int) -> String = { value in
      return UInt16(truncatingIfNeeded: value).hexString
    }
    let hex8: @convention(block) (Int) -> String = { value in
      return UInt8(truncatingIfNeeded: value).hexString
    }
    let log: @convention(block) (Int) -> Void = { value in
      print(value.hexString)
    }

    let scripts: [String: Configuration.Script] = configuration.allScripts()
    for script in scripts.values {
      script.context.setObject(getROMData, forKeyedSubscript: "getROMData" as NSString)
      script.context.setObject(registerText, forKeyedSubscript: "registerText" as NSString)
      script.context.setObject(registerData, forKeyedSubscript: "registerData" as NSString)
      script.context.setObject(registerJumpTable, forKeyedSubscript: "registerJumpTable" as NSString)
      script.context.setObject(registerTransferOfControl, forKeyedSubscript: "registerTransferOfControl" as NSString)
      script.context.setObject(registerFunction, forKeyedSubscript: "registerFunction" as NSString)
      script.context.setObject(registerBankChange, forKeyedSubscript: "registerBankChange" as NSString)
      script.context.setObject(hex16, forKeyedSubscript: "hex16" as NSString)
      script.context.setObject(hex8, forKeyedSubscript: "hex8" as NSString)
      script.context.setObject(log, forKeyedSubscript: "log" as NSString)
    }

    // Extract any scripted events.
    let disassemblyWillStarts = scripts.values.filter { $0.disassemblyWillStart != nil }
    guard !disassemblyWillStarts.isEmpty else {
      return  // Nothing to do here.
    }

    for script in disassemblyWillStarts {
      script.disassemblyWillStart?.call(withArguments: [])
    }
  }

  public func disassemble() {
    for (address, _) in configuration.allGlobals() {
      if address < 0x4000 {
        let location = Cartridge.Location(address: address, bank: 0x01)
        registerData(at: location)
      }
    }

    for potentialCodeRegion in configuration.allPotentialCode().sorted(by: { (a: Range<Cartridge.Location>, b: Range<Cartridge.Location>) -> Bool in
      a.lowerBound < b.lowerBound
    }) {
      disassemble(range: potentialCodeRegion)
    }
  }

  private static func disassembleInstructionSpec(at pc: inout LR35902.Address, memory: DisassemblerMemory) -> LR35902.Instruction.Spec {
    // Fetch
    let instructionByte = memory.read(from: pc)
    pc += 1

    // Decode
    let spec = LR35902.InstructionSet.table[Int(truncatingIfNeeded: instructionByte)]
    if let prefixTable = LR35902.InstructionSet.prefixTables[spec] {
      // Fetch
      let cbInstructionByte = memory.read(from: pc)
      pc += 1

      // Decode
      return prefixTable[Int(truncatingIfNeeded: cbInstructionByte)]
    }
    return spec
  }

  private static func disassembleInstruction(at address: inout LR35902.Address, memory: DisassemblerMemory) -> LR35902.Instruction {
    let spec = disassembleInstructionSpec(at: &address, memory: memory)

    guard let instructionWidth = LR35902.InstructionSet.widths[spec] else {
      preconditionFailure("\(spec) is missing its width, implying a misconfiguration of the instruction set."
                            + " Verify that all specifications are computing and storing a corresponding width in the"
                            + " instruction set's width table.")
    }

    if instructionWidth.operand > 0 {
      var operandBytes: [UInt8] = []
      for _ in 0..<Int(instructionWidth.operand) {
        let byte = memory.read(from: address)
        address += 1
        operandBytes.append(byte)
      }
      return LR35902.Instruction(spec: spec, immediate: LR35902.Instruction.ImmediateValue(data: Data(operandBytes)))
    }

    return LR35902.Instruction(spec: spec, immediate: nil)
  }

  private func disassemble(range: Range<Cartridge.Location>) {
    var visitedAddresses = IndexSet()

    let runQueue = Queue<Disassembler.Run>()
    let firstRun = Run(from: range.lowerBound.address, selectedBank: range.lowerBound.bank, upTo: range.upperBound.address)
    runQueue.add(firstRun)

    let queueRun: (Run, LR35902.Address, LR35902.Address, Cartridge.Bank, LR35902.Instruction) -> Void = { fromRun, fromAddress, toAddress, bank, instruction in
      guard toAddress < 0x8000 else {
        return // We can't disassemble in-memory regions.
      }
      let run = Run(from: toAddress, selectedBank: bank)
      run.invocationInstruction = instruction
      runQueue.add(run)

      fromRun.children.append(run)

      self.registerTransferOfControl(to: Cartridge.Location(address: toAddress, bank: bank),
                                     from: Cartridge.Location(address: fromAddress, bank: bank),
                                     spec: instruction.spec)
    }

    // Extract any scripted events.
    let scripts: [String: Configuration.Script] = configuration.allScripts()
    let linearSweepDidSteps = scripts.values.filter { $0.linearSweepDidStep != nil }
    let linearSweepWillStarts = scripts.values.filter { $0.linearSweepWillStart != nil }

    while !runQueue.isEmpty {
      linearSweepWillStarts.forEach {
        $0.linearSweepWillStart?.call(withArguments: [])
      }

      let run = runQueue.dequeue()

      if visitedAddresses.contains(run.startLocation.index) {
        // We've already visited this instruction, so we can skip it.
        continue
      }

      // Initialize the run's program counter
      var runContext = (pc: run.startLocation.address, bank: run.selectedBank)

      // Script functions
      let registerBankChange: @convention(block) (Int, Int, Int) -> Void = { [weak self] _desiredBank, address, bank in
        guard let self = self else {
          return
        }
        let desiredBank = Cartridge.Bank(truncatingIfNeeded: _desiredBank)
        let location = Cartridge.Location(address: LR35902.Address(truncatingIfNeeded: address),
                                          bank: Cartridge.Bank(truncatingIfNeeded: bank))
        self.registerBankChange(to: max(1, desiredBank), at: location)
        runContext.bank = desiredBank
      }
      for script in scripts.values {
        script.context.setObject(registerBankChange, forKeyedSubscript: "registerBankChange" as NSString)
      }

      let advance: (LR35902.Address) -> Void = { amount in
        let currentCartAddress = Cartridge.Location(address: runContext.pc, bank: runContext.bank)
        run.visitedRange = run.startLocation..<(currentCartAddress + amount)

        visitedAddresses.insert(integersIn: currentCartAddress.index..<(currentCartAddress + amount).index)

        runContext.pc += amount
      }

      var previousInstruction: LR35902.Instruction? = nil
      linear_sweep: while !run.hasReachedEnd(pc: runContext.pc) && pcIsValid(pc: runContext.pc, bank: runContext.bank) {
        let location = Cartridge.Location(address: runContext.pc, bank: runContext.bank)
        if configuration.shouldTerminateLinearSweep(at: location) {
          break
        }
        if data.contains(location.index) || text.contains(location.index) {
          advance(1)
          continue
        }

        let instructionContext = runContext

        // Don't commit the fetch to the context pc yet in case the instruction was invalid.
        var instructionPc = runContext.pc
        memory.selectedBank = runContext.bank
        let instruction = Disassembler.disassembleInstruction(at: &instructionPc, memory: memory)

        // STOP must be followed by 0
        if case .stop = instruction.spec, case let .imm8(immediate) = instruction.immediate, immediate != 0 {
          // STOP wasn't followed by a 0, so skip this byte.
          advance(1)
          continue
        }

        if case .invalid = instruction.spec {
          // This isn't a valid instruction; skip it.
          advance(1)
          continue
        }

        register(instruction: instruction, at: Cartridge.Location(address: instructionContext.pc, bank: instructionContext.bank))

        if let bankChange = bankChange(at: Cartridge.Location(address: instructionContext.pc,
                                                              bank: instructionContext.bank)) {
          runContext.bank = bankChange
        }

        let instructionWidth = LR35902.InstructionSet.widths[instruction.spec]!
        advance(instructionWidth.total)

        let instructionContextLocation = Cartridge.Location(address: instructionContext.pc, bank: instructionContext.bank)
        switch instruction.spec {
        // TODO: Rewrite these with a macro dector during disassembly time.
        case .ld(.imm16addr, .a):
          if case let .imm16(immediate) = instruction.immediate,
             (0x2000..<0x4000).contains(immediate),
             let previousInstruction = previousInstruction,
             case .ld(.a, .imm8) = previousInstruction.spec {
            guard case let .imm8(previousImmediate) = previousInstruction.immediate else {
              preconditionFailure("Invalid immediate associated with instruction")
            }
            self.registerBankChange(to: previousImmediate, at: instructionContextLocation)

            runContext.bank = previousImmediate
          }
        case .ld(.hladdr, .imm8):
          if case .ld(.hl, .imm16) = previousInstruction?.spec,
             case let .imm16(previousImmediate) = previousInstruction?.immediate,
             case let .imm8(immediate) = instruction.immediate,
             (0x2000..<0x4000).contains(previousImmediate) {
            self.registerBankChange(to: immediate, at: instructionContextLocation)
            runContext.bank = immediate
          }

        case .jr(let condition, .simm8):
          guard case let .imm8(immediate) = instruction.immediate else {
            preconditionFailure("Invalid immediate associated with instruction")
          }
          let relativeJumpAmount = Int8(bitPattern: immediate)
          let jumpTo = runContext.pc.advanced(by: Int(relativeJumpAmount))
          queueRun(run, instructionContext.pc, jumpTo, instructionContext.bank, instruction)

          // An unconditional jr is the end of the run.
          if condition == nil {
            break linear_sweep
          }

        case .jp(let condition, .imm16):
          guard case let .imm16(immediate) = instruction.immediate else {
            preconditionFailure("Invalid immediate associated with instruction")
          }
          let jumpTo = immediate
          if jumpTo < 0x8000 {
            queueRun(run, instructionContext.pc, jumpTo, (instructionContext.bank == 0 ? 1 : instructionContext.bank), instruction)
          }

          // An unconditional jp is the end of the run.
          if condition == nil {
            break linear_sweep
          }

        case .call(_, .imm16):
          // TODO: Allow the user to define macros like this.
          guard case let .imm16(immediate) = instruction.immediate else {
            preconditionFailure("Invalid immediate associated with instruction")
          }
          let jumpTo = immediate
          if jumpTo < 0x8000 {
            queueRun(run, instructionContext.pc, jumpTo, instructionContext.bank, instruction)
          }

        case .jp(nil, _), .ret(nil), .reti:
          break linear_sweep

        // TODO: This is specific to the rom; make it possible to pull this out.
        case .rst(.x00):
          break linear_sweep

        default:
          break
        }

        // linearSweepDidStep event
        if !linearSweepDidSteps.isEmpty {
          let args: [Any] = [
            LR35902.InstructionSet.opcodeBytes[instruction.spec]!,
            instruction.immediate?.asInt() ?? 0,
            instructionContext.pc,
            instructionContext.bank
          ]
          for linearSweepDidStep in linearSweepDidSteps {
            linearSweepDidStep.linearSweepDidStep?.call(withArguments: args)
          }
        }

        previousInstruction = instruction
      }
    }

    rewriteScopes(firstRun)
  }
}
