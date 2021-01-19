import Foundation

extension Disassembler {
  enum LabelType {
    case transferOfControlType
    case elseType
    case returnType
    case loopType
  }

  /** Returns the label at the given location, if any. */
  func label(at pc: LR35902.Address, in bank: Cartridge.Bank) -> String? {
    guard let location: Cartridge.Location = Cartridge.location(for: pc, in: bank) else {
      return nil
    }
    guard canShowLabel(at: location) else {
      return nil
    }

    let name: String
    if let explicitName: String = labelNames[location] {
      name = explicitName
    } else if let labelType: LabelType = labelTypes[location] {
      let bank: Cartridge.Bank = (pc < 0x4000) ? 1 : bank
      switch labelType {
      case .transferOfControlType: name = "toc_\(bank.hexString)_\(pc.hexString)"
      case .elseType:              name = "else_\(bank.hexString)_\(pc.hexString)"
      case .loopType:              name = "loop_\(bank.hexString)_\(pc.hexString)"
      case .returnType:            name = "return_\(bank.hexString)_\(pc.hexString)"
      }
    } else {
      return nil
    }

    let scopes: Set<Range<Cartridge.Location>> = contiguousScopes(at: pc, in: bank)
    if let firstScope: Range<Cartridge.Location> = scopes.filter({ (scope: Range<Cartridge.Location>) -> Bool in
      scope.lowerBound != location // Ignore ourself.
    }).min(by: { (scope1: Range<Cartridge.Location>, scope2: Range<Cartridge.Location>) -> Bool in
      scope1.lowerBound < scope2.lowerBound
    }) {
      let addressAndBank: (address: LR35902.Address, bank: Cartridge.Bank) =
        Cartridge.addressAndBank(from: firstScope.lowerBound)
      if let firstScopeLabel: String = label(at: addressAndBank.address, in: addressAndBank.bank)?.components(separatedBy: ".").first {
        return firstScopeLabel + "." + name
      }
    }

    return name
  }

  /** Returns the locations of any labels within the given range. */
  func labelLocations(in range: Range<Cartridge.Location>) -> [Cartridge.Location] {
    return range.filter { (location: Cartridge.Location) -> Bool in
      guard labelNames[location] != nil || labelTypes[location] != nil else {
        return false
      }
      return canShowLabel(at: location)
    }
  }

  /** Registers a label name at a specific location. */
  public func registerLabel(at pc: LR35902.Address, in bank: Cartridge.Bank, named name: String) {
    // TODO: Make this throw an exception that can be presented to the user.
    precondition(!name.contains("."), "Labels cannot contain dots.")
    guard let cartridgeLocation: Cartridge.Location = Cartridge.location(for: pc, inHumanProvided: bank) else {
      preconditionFailure("Setting a label in a non-cart addressable location is not yet supported.")
    }
    labelNames[cartridgeLocation] = name
  }

  /** Returns false if the location should not be able to show a label. */
  private func canShowLabel(at location: Cartridge.Location) -> Bool {
    let intLocation: Int = Int(truncatingIfNeeded: location)
    // Don't return labels that point to the middle of instructions.
    if instructionMap[location] == nil && code.contains(intLocation) {
      return false
    }
    // Don't return labels that point to the middle of data.
    if dataBlocks.contains(intLocation) {
      return false
    }
    return true
  }
}
