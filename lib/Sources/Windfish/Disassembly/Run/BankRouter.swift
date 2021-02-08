import Foundation

import CPU
import Tracing

extension Disassembler {
  final class BankRouter {
    private let context: Configuration
    private var disassembling: Bool = false

    let bankWorkers: ContiguousArray<BankWorker>
    let workGroup = DispatchGroup()

    init(numberOfBanks: Int, context: Configuration) {
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
      guard run.startLocation.bankIndex < bankWorkers.count else {
        return
      }
      disassembling = true
      let bankWorker: BankWorker = bankWorkers[Int(truncatingIfNeeded: run.startLocation.bankIndex)]
      bankWorker.schedule(run: run)
    }

    func finish() {
      // Wait for all scheduled runs to conclude.
      workGroup.wait()

      // Post-process the disassembly by sharding rungroups out to banks and determining scopes.
      var bankedRunGroups: [Cartridge.Bank: [RunGroup]] = [:]
      for bankWorker: BankWorker in bankWorkers {
        for run: Run in bankWorker.runs {
          for runGroup: RunGroup in run.runGroups() {
            bankedRunGroups[runGroup.startLocation!.bankIndex, default: []].append(runGroup)
          }
        }
      }
      for bankWorker: BankWorker in bankWorkers {
        guard let runGroups = bankedRunGroups[bankWorker.bank] else {
          continue
        }
        bankWorker.rewriteRunGroups(runGroups)
      }

      // Wait for scope rewriting to conclude.
      workGroup.wait()

      disassembling = false
    }

    func registerTransferOfControl(to toLocation: Cartridge.Location,
                                   from fromLocation: Cartridge.Location) {
      guard toLocation.bankIndex < bankWorkers.count else {
        return
      }
      let bankWorker: BankWorker = bankWorkers[Int(truncatingIfNeeded: toLocation.bankIndex)]
      if !disassembling {
        // No need to worry about synchronization yet.
        bankWorker.registerTransferOfControl(to: toLocation, from: fromLocation)
        return
      }

      workGroup.enter()
      bankWorker.queue.async {
        bankWorker.registerTransferOfControl(to: toLocation, from: fromLocation)
        self.workGroup.leave()
      }
    }
  }
}
