import Foundation

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

    fileprivate weak var router: BankRouter?
    private let queue: DispatchQueue
    private var runs: [Run] = []

    private let linearSweepDidSteps: [Configuration.Script]
    private let linearSweepWillStarts: [Configuration.Script]

    init(bank: Cartridge.Bank, context: DisassemblerContext) {
      self.bank = bank
      self.context = context
      self.queue = DispatchQueue(label: "Bank worker $\(bank.hexString)",
                                 qos: .userInitiated,
                                 attributes: [],
                                 autoreleaseFrequency: .workItem,
                                 target: nil)
      let scripts: [String: Configuration.Script] = context.allScripts()
      self.linearSweepDidSteps = scripts.values.filter { $0.linearSweepDidStep != nil }
      self.linearSweepWillStarts = scripts.values.filter { $0.linearSweepWillStart != nil }
    }

    /** All cartridge locations that have been visited so far during disassembly. */
    var visitedAddresses = IndexSet()

    // MARK: - Scheduling runs

    fileprivate func schedule(run: Run) {
      runs.append(run)

      router?.workGroup.enter()
      queue.async {
        defer {
          self.router?.workGroup.leave()
        }

        // TODO: Do something with the run.
        print("[worker \(self.bank.hexString)] Running \(run.startLocation.bank.hexString):\(run.startLocation.address.hexString)")

        print("[worker \(self.bank.hexString)] Finished \(run.startLocation.bank.hexString):\(run.startLocation.address.hexString)")
      }
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

    /** Which instruction exists at a specific location. */
    var instructionMap: [Cartridge.Location: LR35902.Instruction] = [:]

    /** Locations that can transfer control (jp/call) to a specific location. */
    private var transfers: [Cartridge.Location: Set<Cartridge.Location>] = [:]

    /** Each bank tracks ranges of code that represent contiguous scopes of instructions. */
    private var contiguousScopes: Set<Range<Cartridge.Location>> = Set<Range<Cartridge.Location>>()

    /** Hints to the disassembler that a given location should be represented by a specific data type. */
    var typeAtLocation: [Cartridge.Location: String] = [:]

    /**
     Label types at specific locations.

     There does not always need to be a corresponding name set in the labelNames dictionary.
     */
    var labelTypes: [Cartridge.Location: LabelType] = [:]

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

    // MARK: - Querying discovered information

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
