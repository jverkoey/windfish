import Foundation

extension Disassembler {
  enum LabelType {
    case transferOfControlType
    case elseType
    case returnType
    case loopType
  }

  /** Returns the label at the given location, if any. */
  func label(at location: Cartridge.Location) -> String? {
    guard canShowLabel(at: location) else {
      return nil
    }

    let name: String
    if let explicitName: String = configuration.label(at: location) {
      name = explicitName
    } else if let labelType: LabelType = labelTypes[location] {
      let bank: Cartridge.Bank = effectiveBank(at: location.address, in: location.bank)
      switch labelType {
      case .transferOfControlType: name = "toc_\(bank.hexString)_\(location.address.hexString)"
      case .elseType:              name = "else_\(bank.hexString)_\(location.address.hexString)"
      case .loopType:              name = "loop_\(bank.hexString)_\(location.address.hexString)"
      case .returnType:            name = "return_\(bank.hexString)_\(location.address.hexString)"
      }
    } else {
      return nil
    }

    let scopes: Set<Range<Cartridge.Location>> = contiguousScopes(at: location)
    if let firstScope: Range<Cartridge.Location> = scopes.filter({ (scope: Range<Cartridge.Location>) -> Bool in
      scope.lowerBound != location // Ignore ourself.
    }).min(by: { (scope1: Range<Cartridge.Location>, scope2: Range<Cartridge.Location>) -> Bool in
      scope1.lowerBound < scope2.lowerBound
    }) {
      if let firstScopeLabel: String = label(at: firstScope.lowerBound)?.components(separatedBy: ".").first {
        return firstScopeLabel + "." + name
      }
    }

    return name
  }

  /** Returns the locations of any labels within the given range. */
  func labelLocations(in range: Range<Cartridge.Location>) -> [Cartridge.Location] {
    return range.filter { (location: Cartridge.Location) -> Bool in
      guard configuration.label(at: location) != nil || labelTypes[location] != nil else {
        return false
      }
      return canShowLabel(at: location)
    }
  }

  /** Returns false if the location should not be able to show a label. */
  private func canShowLabel(at location: Cartridge.Location) -> Bool {
    guard location.address < 0x8000 else {
      return false  // Only show labels in cartridge data.
    }

    let index: Int = location.index
    // Don't return labels that point to the middle of instructions.
    if instructionMap[location] == nil && code.contains(index) {
      return false
    }
    // Don't return labels that point to the middle of data.
    if dataBlocks.contains(index) {
      return false
    }
    return true
  }
}
