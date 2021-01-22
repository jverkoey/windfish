import Foundation

extension Disassembler {
  public final class Run {
    typealias SpecT = LR35902.Instruction.SpecType

    let startLocation: Cartridge._Location
    let endLocation: Cartridge._Location?
    let initialBank: Cartridge.Bank

    init(from startAddress: LR35902.Address,
         initialBank unsafeInitialBank: Cartridge.Bank,
         upTo endAddress: LR35902.Address? = nil) {
      let initialBank = max(1, unsafeInitialBank)
      self.startLocation = Cartridge.location(for: startAddress, inHumanProvided: initialBank)!
      if let endAddress = endAddress, endAddress > 0 {
        self.endLocation = Cartridge.location(for: endAddress - 1, inHumanProvided: initialBank)!
      } else {
        self.endLocation = nil
      }
      self.initialBank = initialBank
    }

    var visitedRange: Range<Cartridge._Location>?

    var children: [Run] = []

    var invocationInstruction: LR35902.Instruction?

    func hasReachedEnd(pc: LR35902.Address) -> Bool {
      if let endAddress = endLocation {
        return pc > Cartridge.addressAndBank(from: endAddress).address
      }
      return false
    }
  }
}
