import Foundation

import Tracing

extension Disassembler.BankRouter {
  /** Get all of the transfers of control to the given location. */
  func transfersOfControl(at location: Cartridge.Location) -> Set<Cartridge.Location>? {
    guard location.bankIndex < bankWorkers.count else {
      return nil
    }
    return bankWorkers[Int(truncatingIfNeeded: location.bankIndex)].transfersOfControl(at: location)
  }
}

extension Disassembler.BankWorker {
  /** Get all of the transfers of control to the given location. */
  func transfersOfControl(at location: Cartridge.Location) -> Set<Cartridge.Location>? {
    return transfers[location.address]
  }

  /** Register a new transfer of control to a given location from another location. */
  func registerTransferOfControl(to toLocation: Cartridge.Location,
                                 from fromLocation: Cartridge.Location) {
    guard toLocation.bankIndex == bank else {
      router?.registerTransferOfControl(to: toLocation, from: fromLocation)
      return
    }

    assert(toLocation.bankIndex == bank)
    transfers[toLocation.address, default: Set()].insert(fromLocation)

    // Tag the label type at this address
    if labelTypes[toLocation.address] == nil
        // Don't create a label in the middle of an instruction.
        && (!code.contains(toLocation.index) || instruction(at: toLocation) != nil) {
      labelTypes[toLocation.address] = .transferOfControl
    }
  }
}
