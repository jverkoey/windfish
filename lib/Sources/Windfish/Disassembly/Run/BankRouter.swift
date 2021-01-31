import Foundation

extension Disassembler {
  final class BankRouter {
    let bankWorkers: ContiguousArray<BankWorker>
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
      let bankWorker = bankWorkers[Int(truncatingIfNeeded: run.startLocation.bank)]
      bankWorker.schedule(run: run)
    }
  }

  final class BankWorker {
    weak var router: BankRouter?
    private let queue: DispatchQueue

    init(bank: Cartridge.Bank) {
      self.queue = DispatchQueue(label: "Bank worker $\(bank.hexString)",
                                 qos: .userInitiated,
                                 attributes: [],
                                 autoreleaseFrequency: .workItem,
                                 target: nil)
    }

    func schedule(run: Run) {
      queue.async {
        // TODO: Do something with the run.
      }
    }
  }
}
