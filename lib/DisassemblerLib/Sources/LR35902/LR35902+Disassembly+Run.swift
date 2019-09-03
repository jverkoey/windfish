import Foundation
import Disassembler

extension LR35902.Disassembly {
  final class Run: Disassembler.Run {
    let startAddress: LR35902.CartridgeLocation
    let endAddress: LR35902.CartridgeLocation?
    let initialBank: LR35902.Bank

    // TODO: Accept a CartridgeLocation here instead.
    init(from startAddress: LR35902.Address, initialBank: LR35902.Bank, upTo endAddress: LR35902.Address? = nil) {
      self.startAddress = LR35902.safeCartAddress(for: startAddress, in: initialBank)!
      if let endAddress = endAddress, endAddress > 0 {
        self.endAddress = LR35902.safeCartAddress(for: endAddress - 1, in: initialBank)!
      } else {
        self.endAddress = nil
      }
      self.initialBank = initialBank
    }

    var visitedRange: Range<LR35902.CartridgeLocation>?

    var children: [Run] = []

    var invocationInstruction: LR35902.Instruction?

    func hasReachedEnd(with cpu: LR35902) -> Bool {
      if let endAddress = endAddress {
        return cpu.pc > LR35902.addressAndBank(from: endAddress).address
      }
      return false
    }
  }
}
