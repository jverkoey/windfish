import Foundation

extension Disassembler {
  /** Get all of the transfers of control to the given location. */
  func transfersOfControl(at pc: LR35902.Address, in bank: Cartridge.Bank) -> Set<Cartridge.Location>? {
    precondition(bank > 0)
    guard let cartridgeLocation: Cartridge.Location = Cartridge.location(for: pc, in: bank) else {
      return nil
    }
    return transfers[cartridgeLocation]
  }

  /** Register a new transfer of control to a given location from another location. */
  public func registerTransferOfControl(to pc: LR35902.Address,
                                        in bank: Cartridge.Bank,
                                        from fromPc: LR35902.Address,
                                        in fromBank: Cartridge.Bank,
                                        spec: LR35902.Instruction.Spec) {
    precondition(bank > 0)
    guard let toLocation: Cartridge.Location = Cartridge.location(for: pc, in: bank),
          let fromLocation: Cartridge.Location = Cartridge.location(for: fromPc, in: fromBank) else {
      return
    }
    transfers[toLocation, default: Set()].insert(fromLocation)

    // Tag the label type at this address
    if labelTypes[toLocation] == nil
        // Don't create a label in the middle of an instruction.
        && (!code.contains(Int(truncatingIfNeeded: toLocation)) || instruction(at: pc, in: bank) != nil) {
      labelTypes[toLocation] = .transferOfControlType
    }
  }
}
