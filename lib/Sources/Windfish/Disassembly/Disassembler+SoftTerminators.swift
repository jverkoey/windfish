import Foundation

extension Disassembler {
  /** Registers a soft terminator at the given location. */
  func registerSoftTerminator(at pc: LR35902.Address, in bank: Cartridge.Bank) {
    guard let location: Cartridge._Location = Cartridge.location(for: pc, in: bank) else {
      return
    }
    softTerminators[location] = true
  }
}
