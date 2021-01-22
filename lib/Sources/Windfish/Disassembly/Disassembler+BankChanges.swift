import Foundation

extension Disassembler {
  /** Returns the bank set at this location, if any. */
  func bankChange(at location: Cartridge.Location) -> Cartridge.Bank? {
    return bankChanges[location]
  }

  /** Registers a bank change at a specific location. */
  func registerBankChange(to: Cartridge.Bank, at location: Cartridge.Location) {
    bankChanges[location] = to
  }
}
