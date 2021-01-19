import Foundation

extension Disassembler {
  /** Returns the bank set at this location, if any. */
  func bankChange(at pc: LR35902.Address, in bank: Cartridge.Bank) -> Cartridge.Bank? {
    guard let location = Cartridge.location(for: pc, in: bank) else {
      return nil
    }
    return bankChanges[location]
  }

  /** Registers a bank change at a specific location. */
  func registerBankChange(to: Cartridge.Bank, at pc: LR35902.Address, in bank: Cartridge.Bank) {
    guard let location = Cartridge.location(for: pc, in: bank) else {
      return
    }
    bankChanges[location] = to
  }
}
