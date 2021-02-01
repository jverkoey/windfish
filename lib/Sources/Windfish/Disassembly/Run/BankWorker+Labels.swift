import Foundation

extension Disassembler.BankRouter {

  /** Returns the label at the given location, if any. */
  func label(at location: Cartridge.Location) -> String? {
    guard location.bankIndex < bankWorkers.count else {
      return nil
    }
    return bankWorkers[Int(truncatingIfNeeded: location.bankIndex)].label(at: location)
  }
}

extension Disassembler.BankWorker {
  enum LabelType {
    case transferOfControl
    case logicalElse
    case returnTransfer
    case doWhile
  }

  /** Returns the label at the given location, if any. */
  func label(at location: Cartridge.Location) -> String? {
    assert(location.bankIndex == bank)
    guard canShowLabel(at: location) else {
      return nil
    }

    let name: String
    if let explicitName: String = context.label(at: location) {
      name = explicitName
    } else if let labelType: LabelType = labelTypes[location.address] {
      switch labelType {
      case .transferOfControl: name = "toc_\(location.bank.hexString)_\(location.address.hexString)"
      case .logicalElse:       name = "else_\(location.bank.hexString)_\(location.address.hexString)"
      case .doWhile:           name = "loop_\(location.bank.hexString)_\(location.address.hexString)"
      case .returnTransfer:    name = "return_\(location.bank.hexString)_\(location.address.hexString)"
      }
    } else {
      return nil
    }

    let scopes: Set<Cartridge.Location> = contiguousScopes(at: location)
    if let firstScope: Cartridge.Location = scopes.filter({ (scopeStartLocation: Cartridge.Location) -> Bool in
      scopeStartLocation != location // Ignore ourself.
    }).min(by: { (scope1: Cartridge.Location, scope2: Cartridge.Location) -> Bool in
      scope1 < scope2
    }) {
      if let firstScopeLabel: String = label(at: firstScope)?.components(separatedBy: ".").first {
        return firstScopeLabel + "." + name
      }
    }

    return name
  }

  /** Returns false if the location should not be able to show a label. */
  private func canShowLabel(at location: Cartridge.Location) -> Bool {
    guard location.address < 0x8000 else {
      return false  // Only show labels in cartridge data.
    }

    let index: Int = location.index
    // Don't return labels that point to the middle of instructions.
    if instructionMap[location.address] == nil && code.contains(index) {
      return false
    }
    // Don't return labels that point to the middle of data.
    if dataBlocks.contains(index) {
      return false
    }
    return true
  }
}
