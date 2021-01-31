import Foundation
import CPU

extension Disassembler {
  final class BankRouter {
    private let context: DisassemblerContext

    private let bankWorkers: ContiguousArray<BankWorker>
    fileprivate let workGroup = DispatchGroup()

    init(numberOfBanks: Int, context: DisassemblerContext) {
      self.context = context
      bankWorkers = ContiguousArray<BankWorker>((0..<numberOfBanks).map({ (index: Int) -> BankWorker in
        BankWorker(bank: Cartridge.Bank(truncatingIfNeeded: index), context: context)
      }))

      // Enable each worker to schedule runs.
      for bankWorker: BankWorker in bankWorkers {
        bankWorker.router = self
      }
    }

    func schedule(run: Run) {
      print("[router] Scheduling \(run.startLocation.bank.hexString):\(run.startLocation.address.hexString)")

      let bankWorker: BankWorker = bankWorkers[Int(truncatingIfNeeded: run.startLocation.bankIndex)]
      bankWorker.schedule(run: run)
    }

    func finish() {
      workGroup.wait()

      for bankWorker: BankWorker in bankWorkers {
        bankWorker.startPostDisassemblyWork()
      }

      workGroup.wait()

      print("All scheduled work has concluded")
    }
  }

  final class BankWorker {
    // Initialization data
    private let bank: Cartridge.Bank
    let context: DisassemblerContext
    private let cartridgeSize: Int
    private let memory: DisassemblerMemory

    fileprivate weak var router: BankRouter?
    private let queue: DispatchQueue
    private var runs: [Run] = []

    private let linearSweepDidSteps: [Configuration.Script]
    private let linearSweepWillStarts: [Configuration.Script]
    private let linearSweepScripts: [Configuration.Script]

    init(bank: Cartridge.Bank, context: DisassemblerContext) {
      self.bank = bank
      self.context = context
      self.cartridgeSize = context.cartridgeData.count
      self.memory = DisassemblerMemory(data: context.cartridgeData)
      self.queue = DispatchQueue(label: "Bank worker $\(bank.hexString)",
                                 qos: .userInitiated,
                                 attributes: [],
                                 autoreleaseFrequency: .workItem,
                                 target: nil)

      let scripts: [String: Configuration.Script] = context.allScripts()
      var linearSweepDidSteps: [Configuration.Script] = []
      var linearSweepWillStarts: [Configuration.Script] = []
      var linearSweepScripts: [Configuration.Script] = []
      for script: Configuration.Script in scripts.values {
        var hasLinearSweepEvent: Bool = false
        if script.linearSweepDidStep != nil {
          linearSweepDidSteps.append(script)
          hasLinearSweepEvent = true
        }
        if script.linearSweepWillStart != nil {
          linearSweepWillStarts.append(script)
          hasLinearSweepEvent = true
        }
        if hasLinearSweepEvent {
          linearSweepScripts.append(script)
        }
      }
      self.linearSweepDidSteps = linearSweepDidSteps
      self.linearSweepWillStarts = linearSweepWillStarts
      self.linearSweepScripts = linearSweepScripts

      // Register linear sweep script functions.
      let changeBank: @convention(block) (Cartridge.Bank, LR35902.Address, Cartridge.Bank) -> Void = { [weak self] desiredBank, address, bank in
        guard let self = self else {
          return
        }
        self.registerBankChange(to: max(1, desiredBank), at: Cartridge.Location(address: address, bank: bank))
        self.currentRun?.selectedBank = desiredBank
      }
      for script in self.linearSweepScripts {
        script.context.setObject(changeBank, forKeyedSubscript: "changeBank" as NSString)
      }
    }

    /** All cartridge locations that have been visited so far during disassembly. */
    var visitedAddresses = IndexSet()

    // MARK: - Scheduling runs

    fileprivate func schedule(run: Run) {
      runs.append(run)

      router?.workGroup.enter()
      queue.async {
        self.disassemble(run: run)
        self.router?.workGroup.leave()
      }
    }

    /** Returns true if the program counter is pointing to addressable memory. */
    private func pcIsValid(pc: LR35902.Address, bank: Cartridge.Bank) -> Bool {
      return pc < 0x8000 && Cartridge.Location(address: pc, bank: bank).index < cartridgeSize
    }

    var currentRun: Run?
    private func disassemble(run: Run) {
      // TODO: Do something with the run.
      print("[worker \(bank.hexString)] Running \(run.startLocation.bank.hexString):\(run.startLocation.address.hexString)")

      if visitedAddresses.contains(run.startLocation.index) {
        // We've already visited this instruction, so we can skip it.
        return
      }

      currentRun = run
      defer {
        currentRun = nil
      }

      linearSweepWillStarts.forEach {
        $0.linearSweepWillStart?.call(withArguments: [])
      }

      let advance: (LR35902.Address) -> Void = { amount in
        self.visitedAddresses.insert(integersIn: run.advance(amount: 56))
      }

      var previousInstruction: LR35902.Instruction? = nil
      linear_sweep: while !run.hasReachedEnd(pc: run.pc) && pcIsValid(pc: run.pc, bank: run.selectedBank) {
        let location = Cartridge.Location(address: run.pc, bank: run.selectedBank)
        if context.shouldTerminateLinearSweep(at: location) {
          break
        }
        if data.contains(location.index) || text.contains(location.index) {
          advance(1)
          continue
        }

        // The conext of the current instruction prior to its execution.
        let instructionContext = (pc: run.pc, selectedBank: run.selectedBank)

        // Don't commit the fetch to the context pc yet in case the instruction was invalid.
        var instructionPc = run.pc
        memory.selectedBank = run.selectedBank
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

        register(instruction: instruction, at: Cartridge.Location(address: instructionContext.pc, bank: instructionContext.selectedBank))

        if let bankChange = bankChange(at: Cartridge.Location(address: instructionContext.pc,
                                                              bank: instructionContext.selectedBank)) {
          run.selectedBank = bankChange
        }

        let instructionWidth = LR35902.InstructionSet.widths[instruction.spec]!
        advance(instructionWidth.total)

        let instructionContextLocation = Cartridge.Location(address: instructionContext.pc, bank: instructionContext.selectedBank)
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

            run.selectedBank = previousImmediate
          }
        case .ld(.hladdr, .imm8):
          if case .ld(.hl, .imm16) = previousInstruction?.spec,
             case let .imm16(previousImmediate) = previousInstruction?.immediate,
             case let .imm8(immediate) = instruction.immediate,
             (0x2000..<0x4000).contains(previousImmediate) {
            self.registerBankChange(to: immediate, at: instructionContextLocation)
            run.selectedBank = immediate
          }

        case .jr(let condition, .simm8):
          guard case let .imm8(immediate) = instruction.immediate else {
            preconditionFailure("Invalid immediate associated with instruction")
          }
          let relativeJumpAmount = Int8(bitPattern: immediate)
          let jumpTo = run.pc.advanced(by: Int(relativeJumpAmount))
          didEncounterTransferOfControl(
            fromRun: run,
            fromAddress: instructionContext.pc,
            toAddress: jumpTo,
            selectedBank: instructionContext.selectedBank,
            instruction: instruction
          )

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
            didEncounterTransferOfControl(
              fromRun: run,
              fromAddress: instructionContext.pc,
              toAddress: jumpTo,
              selectedBank: (instructionContext.selectedBank == 0 ? 1 : instructionContext.selectedBank),
              instruction: instruction
            )
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
            didEncounterTransferOfControl(
              fromRun: run,
              fromAddress: instructionContext.pc,
              toAddress: jumpTo,
              selectedBank: instructionContext.selectedBank,
              instruction: instruction
            )
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
          // TODO: Allow the script to specify which instruction types it cares to be invoked for.
          // This scripting invocation is accounting for 1s out of 4s disassembly time.
          let args: [Any] = [
            LR35902.InstructionSet.opcodeBytes[instruction.spec]!,
            instruction.immediate?.asInt() ?? 0,
            instructionContext.pc,
            instructionContext.selectedBank
          ]
          for linearSweepDidStep in linearSweepDidSteps {
            linearSweepDidStep.linearSweepDidStep?.call(withArguments: args)
          }
        }

        previousInstruction = instruction
      }
      print("[worker \(bank.hexString)] Finished \(run.startLocation.bank.hexString):\(run.startLocation.address.hexString)")
    }

    fileprivate func startPostDisassemblyWork() {
      router?.workGroup.enter()
      queue.async {
        defer {
          self.router?.workGroup.leave()
        }
        for run in self.runs {
          self.rewriteScopes(run)
        }
      }
    }

    // MARK: - Events that occur during a disassembly run

    private func didEncounterTransferOfControl(fromRun: Run, fromAddress: LR35902.Address, toAddress: LR35902.Address, selectedBank: Cartridge.Bank, instruction: LR35902.Instruction) {
      guard toAddress < 0x8000 else {
        return  // We can't disassemble in-memory regions.
      }
      let run = Run(from: toAddress, selectedBank: bank)
      run.invocationInstruction = instruction
      fromRun.children.append(run)

      router?.schedule(run: run)

      registerTransferOfControl(to: Cartridge.Location(address: toAddress, bank: bank),
                                from: Cartridge.Location(address: fromAddress, bank: bank),
                                spec: instruction.spec)
    }

    // MARK: - Registering information discovered during disassembly

    /** All locations that represent code. */
    private var code = IndexSet()

    /** All locations that represent code. */
    private var data = IndexSet()

    /**
     We never want to show labels in the middle of a contiguous block of data, so when registering data regions we remove
     the first byte of the data region and then register that range to this index set. When determining whether a label
     can be shown at a given location we consult this "swiss cheese" index set rather than the data index set.
     */
    var dataBlocks = IndexSet()

    /** All locations that represent code. */
    private var text = IndexSet()

    /** Which instruction exists at a specific location. */
    var instructionMap: [Cartridge.Location: LR35902.Instruction] = [:]

    /** Locations that can transfer control (jp/call) to a specific location. */
    private var transfers: [Cartridge.Location: Set<Cartridge.Location>] = [:]

    /** Tracks ranges of code that represent contiguous scopes of instructions. */
    private var contiguousScopes: Set<Range<Cartridge.Location>> = Set<Range<Cartridge.Location>>()

    /** Hints to the disassembler that a given location should be represented by a specific data type. */
    var typeAtLocation: [Cartridge.Location: String] = [:]

    /** Bank changes that occur at a specific location. */
    private var bankChanges: [Cartridge.Location: Cartridge.Bank] = [:]

    /**
     Label types at specific locations.

     There does not always need to be a corresponding name set in the labelNames dictionary.
     */
    var labelTypes: [Cartridge.Location: LabelType] = [:]

    /** Register an instruction at the given location. */
    func register(instruction: LR35902.Instruction, at location: Cartridge.Location) {
      guard instructionMap[location] == nil else {
        return
      }
      // Don't register instructions in the middle of existing instructions.
      if code.contains(location.index) {
        return
      }

      // Clear any existing instructions in this instruction's footprint.
      let instructionWidths: [LR35902.Instruction.Spec: CPU.InstructionWidth<UInt16>] = LR35902.InstructionSet.widths
      let instructionRange: Range<Cartridge.Location> = location..<(location + instructionWidths[instruction.spec]!.total)
      for clearLocation in instructionRange.dropFirst() {
        deleteInstruction(at: clearLocation)
      }

      instructionMap[location] = instruction
      // Set the code bit for the instruction's footprint.
      registerRegion(range: instructionRange, as: .code)
    }

    /** Register a new transfer of control to a given location from another location. */
    func registerTransferOfControl(to toLocation: Cartridge.Location,
                                   from fromLocation: Cartridge.Location,
                                   spec: LR35902.Instruction.Spec) {
      transfers[toLocation, default: Set()].insert(fromLocation)

      // Tag the label type at this address
      if labelTypes[toLocation] == nil
          // Don't create a label in the middle of an instruction.
          && (!code.contains(toLocation.index) || instruction(at: toLocation) != nil) {
        labelTypes[toLocation] = .transferOfControl
      }
    }

    /** Registers a new contiguous scope at the given range. */
    func registerContiguousScope(range: Range<Cartridge.Location>) {
      contiguousScopes.insert(range)
    }

    /** Registers a bank change at a specific location. */
    func registerBankChange(to: Cartridge.Bank, at location: Cartridge.Location) {
      bankChanges[location] = to
    }

    // MARK: - Querying discovered information

    /** Returns the bank set at this location, if any. */
    func bankChange(at location: Cartridge.Location) -> Cartridge.Bank? {
      return bankChanges[location]
    }

    /** Get the instruction at the given location, if one exists. */
    func instruction(at location: Cartridge.Location) -> LR35902.Instruction? {
      guard code.contains(location.index) else {
        return nil
      }
      return instructionMap[location]
    }

    /** Get all of the transfers of control to the given location. */
    func transfersOfControl(at location: Cartridge.Location) -> Set<Cartridge.Location>? {
      return transfers[location]
    }
  }
}

extension Disassembler.BankWorker {
  enum ByteType {
    case unknown
    case code
    case data
    case jumpTable
    case text
    case image1bpp
    case image2bpp
    case ram
  }

  /** Returns all disassembled locations. */
  func disassembledLocations() -> IndexSet {
    return code.union(data).union(text)
  }

  /** Returns the type of information at the given location. */
  func type(at location: Cartridge.Location) -> ByteType {
    guard location.address < 0x8000 else {
      return .ram
    }
    let index = location.index
    if code.contains(index) {
      return .code
    }
    if data.contains(index) {
      switch context.formatOfData(at: location) {
      case .image1bpp:  return .image1bpp
      case .image2bpp:  return .image2bpp
      case .jumpTable:  return .jumpTable
      case .bytes:      return .data
      case .none:       return .data
      }
    }
    if text.contains(index) {
      return .text
    }
    return .unknown
  }

  public enum RegionCategory {
    case code
    case data
    case text
  }

  /** Registers a range as a specific region category. Will clear any existing regions in the range. */
  func registerRegion(range: Range<Cartridge.Location>, as category: RegionCategory) {
    let intRange = range.asIntRange()
    switch category {
    case .code:
      code.insert(integersIn: intRange)

      clearData(in: range)
      clearText(in: range)

    case .data:
      data.insert(integersIn: intRange)
      if range.count > 1 {
        dataBlocks.insert(integersIn: intRange.dropFirst())
      }

      clearCode(in: range)
      clearText(in: range)

    case .text:
      text.insert(integersIn: intRange)

      clearCode(in: range)
      clearData(in: range)
    }
  }

  /** Deletes an instruction from a specific location and clears any code-related information in its footprint. */
  func deleteInstruction(at location: Cartridge.Location) {
    guard let instruction: LR35902.Instruction = instructionMap[location] else {
      return
    }
    instructionMap[location] = nil

    clearCode(in: location..<(location + LR35902.InstructionSet.widths[instruction.spec]!.total))
  }

  // MARK: Clearing regions

  /** Removes all text-related information from the given range. */
  private func clearText(in range: Range<Cartridge.Location>) {
    text.remove(integersIn: range.asIntRange())
  }

  /** Removes all data-related information from the given range. */
  private func clearData(in range: Range<Cartridge.Location>) {
    let intRange = range.asIntRange()
    data.remove(integersIn: intRange)
    dataBlocks.remove(integersIn: intRange)
  }

  /**
   Removes all code-related information from the given range.

   Note that if an instruction footprint overlaps with the end of the given range then it is possible for some
   additional code to be cleared beyond the range.
   */
  private func clearCode(in range: Range<Cartridge.Location>) {
    let intRange = range.asIntRange()
    code.remove(integersIn: intRange)

    // Remove any labels, instructions, and transfers of control in this range.
    for location: Cartridge.Location in range.dropFirst() {
      deleteInstruction(at: location)
      transfers[location] = nil
      labelTypes[location] = nil
      bankChanges[location] = nil
    }

    // For any existing scope that intersects this range:
    // 1. Shorten it if it begins before the range.
    // 2. Delete it if it begins within the range.
    var mutatedScopes: Set<Range<Cartridge.Location>> = contiguousScopes
    for scope: Range<Cartridge.Location> in contiguousScopes {
      guard scope.overlaps(range) else {
        continue
      }
      mutatedScopes.remove(scope)
      if scope.lowerBound < range.lowerBound {
        mutatedScopes.insert(scope.lowerBound..<range.lowerBound)
      }
    }
    contiguousScopes = mutatedScopes
  }
}
