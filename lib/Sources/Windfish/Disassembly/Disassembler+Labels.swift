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
    guard canShowLabel(at: Cartridge.Location(address: pc, bank: bank)) else {
      return nil
    }

    guard let _location: Cartridge._Location = Cartridge.location(for: pc, in: bank) else {
      return nil
    }
    let name: String
    if let explicitName: String = labelNames[_location] {
      name = explicitName
    } else if let labelType: LabelType = labelTypes[_location] {
      let bank: Cartridge.Bank = effectiveBank(at: pc, in: bank)
      switch labelType {
      case .transferOfControlType: name = "toc_\(bank.hexString)_\(pc.hexString)"
      case .elseType:              name = "else_\(bank.hexString)_\(pc.hexString)"
      case .loopType:              name = "loop_\(bank.hexString)_\(pc.hexString)"
      case .returnType:            name = "return_\(bank.hexString)_\(pc.hexString)"
      }
    } else {
      return nil
    }

    let scopes: Set<Range<Cartridge._Location>> = contiguousScopes(at: Cartridge.Location(address: pc, bank: bank))
    if let firstScope: Range<Cartridge._Location> = scopes.filter({ (scope: Range<Cartridge._Location>) -> Bool in
      scope.lowerBound != _location // Ignore ourself.
    }).min(by: { (scope1: Range<Cartridge._Location>, scope2: Range<Cartridge._Location>) -> Bool in
      scope1.lowerBound < scope2.lowerBound
    }) {
      let scopeLocation: Cartridge.Location = Cartridge.Location(location: firstScope.lowerBound)
      if let firstScopeLabel: String = label(at: scopeLocation.address, in: scopeLocation.bank)?.components(separatedBy: ".").first {
        return firstScopeLabel + "." + name
      }
    }

    return name
  }

  /** Returns the locations of any labels within the given range. */
  func labelLocations(in range: Range<Cartridge._Location>) -> [Cartridge._Location] {
    return range.filter { (location: Cartridge._Location) -> Bool in
      guard labelNames[location] != nil || labelTypes[location] != nil else {
        return false
      }
      return canShowLabel(at: Cartridge.Location(location: location))
    }
  }

  /** Registers a label name at a specific location. */
  public func registerLabel(at location: Cartridge.Location, named name: String) {
    // TODO: Make this throw an exception that can be presented to the user.
    precondition(!name.contains("."), "Labels cannot contain dots.")
    labelNames[Cartridge._Location(truncatingIfNeeded: location.index)] = name
  }

  /** Returns false if the location should not be able to show a label. */
  private func canShowLabel(at location: Cartridge.Location) -> Bool {
    guard location.address < 0x8000 else {
      return false  // Only show labels in cartridge data.
    }

    let index: Int = location.index
    // Don't return labels that point to the middle of instructions.
    if instructionMap[Cartridge._Location(truncatingIfNeeded: location.index)] == nil && code.contains(index) {
      return false
    }
    // Don't return labels that point to the middle of data.
    if dataBlocks.contains(index) {
      return false
    }
    return true
  }
}
