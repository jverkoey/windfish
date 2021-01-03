import Foundation

extension Disassembler {
  public final class Run {
    typealias SpecT = LR35902.Instruction.SpecType

    let startAddress: Gameboy.Cartridge.Location
    let endAddress: Gameboy.Cartridge.Location?
    let initialBank: Gameboy.Cartridge.Bank

    // TODO: Accept a Gameboy.Cartridge.Location here instead.
    init(from startAddress: LR35902.Address, initialBank _initialBank: Gameboy.Cartridge.Bank, upTo endAddress: LR35902.Address? = nil) {
      let initialBank = _initialBank == 0 ? 1 : _initialBank
      self.startAddress = Gameboy.Cartridge.location(for: startAddress, inHumanProvided: initialBank)!
      if let endAddress = endAddress, endAddress > 0 {
        self.endAddress = Gameboy.Cartridge.location(for: endAddress - 1, inHumanProvided: initialBank)!
      } else {
        self.endAddress = nil
      }
      self.initialBank = initialBank
    }

    var visitedRange: Range<Gameboy.Cartridge.Location>?

    var children: [Run] = []

    var invocationInstruction: LR35902.Instruction?

    func hasReachedEnd(pc: LR35902.Address) -> Bool {
      if let endAddress = endAddress {
        return pc > Gameboy.Cartridge.addressAndBank(from: endAddress).address
      }
      return false
    }
  }
}
