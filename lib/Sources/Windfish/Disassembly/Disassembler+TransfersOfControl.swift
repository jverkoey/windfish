import Foundation

extension Disassembler {
  /** Get all of the transfers of control to the given location. */
  func transfersOfControl(at location: Cartridge.Location) -> Set<Cartridge.Location>? {
    return transfers[location]
  }

  /** Register a new transfer of control to a given location from another location. */
  public func registerTransferOfControl(to toLocation: Cartridge.Location,
                                        from fromLocation: Cartridge.Location,
                                        spec: LR35902.Instruction.Spec) {
    transfers[toLocation, default: Set()].insert(fromLocation)

    // Tag the label type at this address
    if labelTypes[toLocation] == nil
        // Don't create a label in the middle of an instruction.
        && (!code.contains(toLocation.index) || instruction(at: toLocation) != nil) {
      labelTypes[toLocation] = .transferOfControlType
    }
  }
}
