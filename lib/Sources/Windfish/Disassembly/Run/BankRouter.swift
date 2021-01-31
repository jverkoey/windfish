import Foundation

extension Disassembler {
  final class BankRouter {
    let bankWorkers: ContiguousArray<BankWorker>
    let workGroup = DispatchGroup()

    init(numberOfBanks: Int) {
      bankWorkers = ContiguousArray<BankWorker>((0..<numberOfBanks).map({ (index: Int) -> BankWorker in
        BankWorker(bank: Cartridge.Bank(truncatingIfNeeded: index))
      }))

      // Enable each worker to schedule runs.
      for bankWorker: BankWorker in bankWorkers {
        bankWorker.router = self
      }
    }

    func schedule(run: Run) {
      workGroup.enter()

      print("[router] Scheduling \(run.startLocation.bank.hexString):\(run.startLocation.address.hexString)")
      let bankWorker = bankWorkers[Int(truncatingIfNeeded: run.startLocation.bankIndex)]
      bankWorker.schedule(run: run)
    }

    func wait() {
      workGroup.wait()

      print("All scheduled work has concluded")
    }
  }

  final class BankWorker {
    // Initialization data
    weak var router: BankRouter?
    private let bank: Cartridge.Bank
    private let queue: DispatchQueue

    init(bank: Cartridge.Bank) {
      self.bank = bank
      self.queue = DispatchQueue(label: "Bank worker $\(bank.hexString)",
                                 qos: .userInitiated,
                                 attributes: [],
                                 autoreleaseFrequency: .workItem,
                                 target: nil)
    }

    // Disassembly information
    var visitedAddresses = IndexSet()

    func schedule(run: Run) {
      queue.async {
        // TODO: Do something with the run.
        print("[worker \(self.bank.hexString)] Running \(run.startLocation.bank.hexString):\(run.startLocation.address.hexString)")

        self.router?.workGroup.leave()

        print("[worker \(self.bank.hexString)] Finished \(run.startLocation.bank.hexString):\(run.startLocation.address.hexString)")
      }
    }
  }
}
