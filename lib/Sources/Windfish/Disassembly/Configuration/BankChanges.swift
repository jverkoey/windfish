import Foundation

extension Disassembler.Configuration {
  func bankChange(at location: Cartridge.Location) -> Cartridge.Bank? {
    return bankChanges[location]
  }

  /** Registers a bank change at a specific location. */
  func registerBankChange(to: Cartridge.Bank, at location: Cartridge.Location) {
    bankChanges[location] = to
  }
}
