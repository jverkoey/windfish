import Foundation

extension Disassembler {
  /** Returns the pre-comment registered at the given location, if any. */
  func preComment(at address: LR35902.Address, in bank: Cartridge.Bank) -> String? {
    guard let location: Cartridge.Location = Cartridge.location(for: address, in: bank) else {
      return nil
    }
    return preComments[location]
  }

  /** Registers a pre-comment at the given location. */
  func registerPreComment(at address: LR35902.Address, in bank: Cartridge.Bank, text: String) {
    guard let location: Cartridge.Location = Cartridge.location(for: address, in: bank) else {
      return
    }
    preComments[location] = text
  }
}
