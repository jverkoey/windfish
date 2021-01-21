import Foundation

extension Disassembler {
  public final class Run {
    typealias SpecT = LR35902.Instruction.SpecType

    let startAddress: Cartridge._Location
    let endAddress: Cartridge._Location?
    let initialBank: Cartridge.Bank

    // TODO: Accept a Cartridge.Location here instead.
    init(from startAddress: LR35902.Address,
         initialBank unsafeInitialBank: Cartridge.Bank,
         upTo endAddress: LR35902.Address? = nil) {
      let initialBank = unsafeInitialBank == 0 ? 1 : unsafeInitialBank
      self.startAddress = Cartridge.location(for: startAddress, inHumanProvided: initialBank)!
      if let endAddress = endAddress, endAddress > 0 {
        self.endAddress = Cartridge.location(for: endAddress - 1, inHumanProvided: initialBank)!
      } else {
        self.endAddress = nil
      }
      self.initialBank = initialBank
    }

    var visitedRange: Range<Cartridge._Location>?

    var children: [Run] = []

    var invocationInstruction: LR35902.Instruction?

    func hasReachedEnd(pc: LR35902.Address) -> Bool {
      if let endAddress = endAddress {
        return pc > Cartridge.addressAndBank(from: endAddress).address
      }
      return false
    }
  }
}
