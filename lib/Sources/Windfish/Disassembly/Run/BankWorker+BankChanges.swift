import Foundation

import Tracing

extension Disassembler.BankRouter {
  /** Registers a range as a specific region category. Will clear any existing regions in the range. */
  func bankChange(at location: Cartridge.Location) -> Cartridge.Bank? {
    return bankWorkers[Int(truncatingIfNeeded: location.bankIndex)].bankChange(at: location)
  }
}

extension Disassembler.BankWorker {
  /** Returns the bank set at this location, if any. */
  func bankChange(at location: Cartridge.Location) -> Cartridge.Bank? {
    assert(location.bankIndex == bank)
    return context.bankChange(at: location) ?? bankChanges[location.address]
  }

  /** Registers a bank change at a specific location. */
  func registerBankChange(to: Cartridge.Bank, at location: Cartridge.Location) {
    assert(location.bankIndex == bank)
    bankChanges[location.address] = to
  }
}
