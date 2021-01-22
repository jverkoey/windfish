import Foundation

extension Disassembler {
  /** Get all of the transfers of control to the given location. */
  func transfersOfControl(at location: Cartridge.Location) -> Set<Cartridge._Location>? {
    return transfers[Cartridge._Location(truncatingIfNeeded: location.index)]
  }

  /** Register a new transfer of control to a given location from another location. */
  public func registerTransferOfControl(to pc: LR35902.Address,
                                        in bank: Cartridge.Bank,
                                        from fromPc: LR35902.Address,
                                        in fromBank: Cartridge.Bank,
                                        spec: LR35902.Instruction.Spec) {
    precondition(bank > 0)
    guard let _toLocation: Cartridge._Location = Cartridge.location(for: pc, in: bank),
          let _fromLocation: Cartridge._Location = Cartridge.location(for: fromPc, in: fromBank) else {
      return
    }
    let toLocation = Cartridge.Location(address: pc, bank: bank)
    transfers[_toLocation, default: Set()].insert(_fromLocation)

    // Tag the label type at this address
    if labelTypes[toLocation] == nil
        // Don't create a label in the middle of an instruction.
        && (!code.contains(Int(truncatingIfNeeded: _toLocation)) || instruction(at: toLocation) != nil) {
      labelTypes[toLocation] = .transferOfControlType
    }
  }
}
