import Foundation

import LR35902
import CPU

extension Disassembler {
  final class BankWorker {
    // Initialization data
    let bank: Cartridge.Bank
    let context: Configuration
    private let cartridgeSize: Int
    private let memory: DisassemblerMemory

    weak var router: BankRouter?
    let queue: DispatchQueue
    var runs: [Run] = []

    private let linearSweepDidSteps: [MutableConfiguration.Script]
    private let linearSweepWillStarts: [MutableConfiguration.Script]
    private let linearSweepScripts: [MutableConfiguration.Script]

    init(bank: Cartridge.Bank, context: Configuration) {
      self.bank = bank
      self.context = context
      self.cartridgeSize = context.cartridgeData.count
      self.memory = DisassemblerMemory(data: context.cartridgeData)
      self.queue = DispatchQueue(label: "Bank worker $\(bank.hexString)",
                                 qos: .userInitiated,
                                 attributes: [],
                                 autoreleaseFrequency: .workItem,
                                 target: nil)

      let scripts: [String: MutableConfiguration.Script] = context.allScripts()
      var linearSweepDidSteps: [MutableConfiguration.Script] = []
      var linearSweepWillStarts: [MutableConfiguration.Script] = []
      var linearSweepScripts: [MutableConfiguration.Script] = []
      for script: MutableConfiguration.Script in scripts.values {
        var hasLinearSweepEvent: Bool = false
        let copiedScript = script.copy()
        if script.linearSweepDidStep != nil {
          linearSweepDidSteps.append(copiedScript)
          hasLinearSweepEvent = true
        }
        if script.linearSweepWillStart != nil {
          linearSweepWillStarts.append(copiedScript)
          hasLinearSweepEvent = true
        }
        if hasLinearSweepEvent {
          linearSweepScripts.append(copiedScript)
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
      let didEncounterTransferOfControl: @convention(block) (Cartridge.Bank, LR35902.Address, Cartridge.Bank, LR35902.Address) -> Void = { [weak self] toBank, toAddress, fromBank, fromAddress in
        guard let self = self,
              let currentRun: Run = self.currentRun,
              let currentInstruction: LR35902.Instruction = self.currentInstruction else {
          return
        }
        self.didEncounterTransferOfControl(
          fromRun: currentRun,
          fromAddress: fromAddress,
          toAddress: toAddress,
          fromBank: fromBank,
          toBank: toBank,
          instruction: currentInstruction
        )
      }
      for script in self.linearSweepScripts {
        script.context.setObject(changeBank, forKeyedSubscript: "changeBank" as NSString)
        script.context.setObject(didEncounterTransferOfControl, forKeyedSubscript: "didEncounterTransferOfControl" as NSString)
      }
    }

    // MARK: - Scheduling runs

    func schedule(run: Run) {
      router?.workGroup.enter()
      queue.async {
        self.runs.append(run)

        self.disassemble(run: run)
        self.router?.workGroup.leave()
      }
    }

    /** Returns true if the program counter is pointing to addressable memory. */
    private func pcIsValid(pc: LR35902.Address, bank: Cartridge.Bank) -> Bool {
      return pc < 0x8000 && Cartridge.Location(address: pc, bank: bank).index < cartridgeSize
    }

    var currentRun: Run?
    var currentInstruction: LR35902.Instruction?
    private func disassemble(run: Run) {
      assert(run.startLocation.bankIndex == bank)

      if code.contains(run.startLocation.index) && instruction(at: run.startLocation) != nil {
        // We've already disassembled on this alignment before; no need to do so again.
        return
      }
      if run.visitHistory[Int(truncatingIfNeeded: bank)].visitedLocations.contains(run.startLocation.index) {
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
        run.visitHistory[Int(truncatingIfNeeded: self.bank)]
          .visitedLocations.insert(integersIn: run.advance(amount: amount))
      }

      var previousInstruction: LR35902.Instruction? = nil
      linear_sweep: while !run.hasReachedEnd() && pcIsValid(pc: run.pc, bank: run.selectedBank) {
        let location = Cartridge.Location(address: run.pc, bank: run.selectedBank)
        if context.shouldTerminateLinearSweep(at: location) {
          break
        }
        if data.contains(location.index) || text.contains(location.index) {
          advance(1)
          continue
        }

        // The context of the current instruction prior to its execution.
        let instructionContext = (pc: run.pc, selectedBank: run.selectedBank)

        // Don't commit the fetch to the context pc yet in case the instruction was invalid.
        var instructionPc = run.pc
        memory.selectedBank = run.selectedBank
        let instruction = Disassembler.disassembleInstruction(at: &instructionPc, memory: memory)
        self.currentInstruction = instruction

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

        let instructionWidth = LR35902.InstructionSet.widths[instruction.spec]!
        advance(instructionWidth.total)

        if let bankChange = bankChange(at: Cartridge.Location(address: instructionContext.pc,
                                                              bank: instructionContext.selectedBank)) {
          run.selectedBank = bankChange
        }

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
            fromBank: max(1, bank),
            toBank: instructionContext.selectedBank,
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
            let tocBank: Cartridge.Bank = max(1, instructionContext.selectedBank)
            didEncounterTransferOfControl(
              fromRun: run,
              fromAddress: instructionContext.pc,
              toAddress: jumpTo,
              fromBank: tocBank,
              toBank: tocBank,
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
            let tocBank: Cartridge.Bank = max(1, instructionContext.selectedBank)
            didEncounterTransferOfControl(
              fromRun: run,
              fromAddress: instructionContext.pc,
              toAddress: jumpTo,
              fromBank: tocBank,
              toBank: tocBank,
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

        if run.pc >= 0x4000 && max(1, run.selectedBank) != max(1, bank) {
          // The bank has changed mid-sweep, meaning we've effectively jumped to a new bank. Register a transfer of
          // control and abandon this sweep.
          let tocBank: Cartridge.Bank = max(1, instructionContext.selectedBank)
          didEncounterTransferOfControl(
            fromRun: run,
            fromAddress: instructionContext.pc,
            toAddress: instructionContext.pc,
            fromBank: tocBank,
            toBank: tocBank,
            instruction: previousInstruction!
          )
          break
        }

        previousInstruction = instruction
      }
    }

    func rewriteRunGroups(_ runGroups: [RunGroup]) {
      router?.workGroup.enter()
      queue.async {
        defer {
          self.router?.workGroup.leave()
        }
        for runGroup in runGroups {
          self.rewriteRunGroup(runGroup)
        }

        self.contiguousScopes = [:]
        for range: Range<Cartridge.Location> in self._contiguousScopes {
          for location: Cartridge.Location in range {
            self.contiguousScopes[location, default: Set()].insert(range.lowerBound)
          }
        }
      }
    }

    // MARK: - Events that occur during a disassembly run

    private func didEncounterTransferOfControl(fromRun: Run, fromAddress: LR35902.Address, toAddress: LR35902.Address, fromBank: Cartridge.Bank, toBank: Cartridge.Bank, instruction: LR35902.Instruction) {
      guard toAddress < 0x8000 else {
        return  // We can't disassemble in-memory regions.
      }
      let run = Run(from: toAddress, selectedBank: toBank, visitHistory: fromRun.visitHistory)
      run.invocationInstruction = instruction
      fromRun.children.append(run)

      router?.schedule(run: run)

      registerTransferOfControl(to: Cartridge.Location(address: toAddress, bank: toBank),
                                from: Cartridge.Location(address: fromAddress, bank: fromBank))
    }

    // MARK: - Registering information discovered during disassembly

    /** All locations that represent code. */
    var code = IndexSet()

    /** All locations that represent code. */
    var data = IndexSet()

    /**
     We never want to show labels in the middle of a contiguous block of data, so when registering data regions we remove
     the first byte of the data region and then register that range to this index set. When determining whether a label
     can be shown at a given location we consult this "swiss cheese" index set rather than the data index set.
     */
    var dataBlocks = IndexSet()

    /** All locations that represent code. */
    var text = IndexSet()

    /** Which instruction exists at a specific address. */
    var instructionMap: [LR35902.Address: LR35902.Instruction] = [:]

    /** Locations that can transfer control (jp/call) to a specific location. */
    var transfers: [LR35902.Address: Set<Cartridge.Location>] = [:]

    /** Tracks ranges of code that represent contiguous scopes of instructions. */
    var _contiguousScopes: Set<Range<Cartridge.Location>> = Set<Range<Cartridge.Location>>()
    var contiguousScopes: [Cartridge.Location: Set<Cartridge.Location>] = [:]

    /** Hints to the disassembler that a given location should be represented by a specific data type. */
    var typeAtLocation: [LR35902.Address: String] = [:]

    /** Bank changes that occur at a specific location. */
    var bankChanges: [LR35902.Address: Cartridge.Bank] = [:]

    /**
     Label types at specific locations.

     There does not always need to be a corresponding name set in the labelNames dictionary.
     */
    var labelTypes: [LR35902.Address: LabelType] = [:]
  }
}
