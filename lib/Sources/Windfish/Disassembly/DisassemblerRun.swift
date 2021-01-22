import Foundation

extension Disassembler {
  public final class Run {
    typealias SpecT = LR35902.Instruction.SpecType

    let startLocation: Cartridge.Location
    let endLocation: Cartridge.Location?
    let initialBank: Cartridge.Bank

    init(from startAddress: LR35902.Address,
         initialBank unsafeInitialBank: Cartridge.Bank,
         upTo endAddress: LR35902.Address? = nil) {
      let initialBank = max(1, unsafeInitialBank)
      self.startLocation = Cartridge.Location(address: startAddress, bank: initialBank)
      if let endAddress = endAddress, endAddress > 0 {
        self.endLocation = Cartridge.Location(address: endAddress - 1, bank: initialBank)
      } else {
        self.endLocation = nil
      }
      self.initialBank = initialBank
    }

    var visitedRange: Range<Cartridge.Location>?

    var children: [Run] = []

    var invocationInstruction: LR35902.Instruction?

    func hasReachedEnd(pc: LR35902.Address) -> Bool {
      guard let endLocation = endLocation else {
        return false
      }
      return pc > endLocation.address
    }
  }
}
