import Foundation

public final class LR35902 {
  public typealias Address = UInt16
  public typealias Bank = UInt8

  // TODO: Move these into the disassembler and CPUState so that they can be tracked independently.
  public var pc: Address = 0
  public var bank: Bank = 0

  static let bankSize: Cartridge.Location = 0x4000

  init(cartridge: Cartridge) {
    self.cartridge = cartridge
  }
  public var cartridge: Cartridge
}

// MARK: - Evaluating the current state of the CPU

extension LR35902 {
  /** Returns true if the program counter is pointing to addressable memory. */
  func pcIsValid() -> Bool {
    return
      ((bank == 0 && pc < 0x4000)
        || (bank != 0 && pc < 0x8000))
      && LR35902.Cartridge.location(for: pc, in: bank)! < cartridge.size
  }
}
