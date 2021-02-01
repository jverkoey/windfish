import Foundation

extension Disassembler.BankRouter {

  /** Returns all disassembled locations. */
  func disassembledLocations() -> IndexSet {
    var indexSet: IndexSet = IndexSet()
    for bankWorker: Disassembler.BankWorker in bankWorkers {
      indexSet = indexSet.union(bankWorker.disassembledLocations())
    }
    return indexSet
  }

  /** Registers a range as a specific region category. Will clear any existing regions in the range. */
  func registerRegion(range: Range<Cartridge.Location>, as category: Disassembler.BankWorker.RegionCategory) {
    bankWorkers[Int(truncatingIfNeeded: range.lowerBound.bankIndex)].registerRegion(range: range, as: category)
  }

  /** Returns the type of information at the given location. */
  func disassemblyType(at location: Cartridge.Location) -> Disassembler.BankWorker.ByteType {
    bankWorkers[Int(truncatingIfNeeded: location.bankIndex)].type(at: location)
  }
}

extension Disassembler.BankWorker {
  enum ByteType {
    case unknown
    case code
    case data
    case jumpTable
    case text
    case image1bpp
    case image2bpp
    case ram
  }

  /** Returns all disassembled locations. */
  func disassembledLocations() -> IndexSet {
    return code.union(data).union(text)
  }

  /** Returns the type of information at the given location. */
  func type(at location: Cartridge.Location) -> ByteType {
    assert(location.bankIndex == bank)
    guard location.address < 0x8000 else {
      return .ram
    }
    let index = location.index
    if code.contains(index) {
      return .code
    }
    if data.contains(index) {
      switch context.formatOfData(at: location) {
      case .image1bpp:  return .image1bpp
      case .image2bpp:  return .image2bpp
      case .jumpTable:  return .jumpTable
      case .bytes:      return .data
      case .none:       return .data
      }
    }
    if text.contains(index) {
      return .text
    }
    return .unknown
  }

  public enum RegionCategory {
    case code
    case data
    case text
  }

  /** Registers a range as a specific region category. Will clear any existing regions in the range. */
  func registerRegion(range: Range<Cartridge.Location>, as category: RegionCategory) {
    assert(range.lowerBound.bankIndex == bank)
    let intRange = range.asIntRange()
    switch category {
    case .code:
      code.insert(integersIn: intRange)

      clearData(in: range)
      clearText(in: range)

    case .data:
      data.insert(integersIn: intRange)
      if range.count > 1 {
        dataBlocks.insert(integersIn: intRange.dropFirst())
      }

      clearCode(in: range)
      clearText(in: range)

    case .text:
      text.insert(integersIn: intRange)

      clearCode(in: range)
      clearData(in: range)
    }
  }

  /** Deletes an instruction from a specific location and clears any code-related information in its footprint. */
  func deleteInstruction(at location: Cartridge.Location) {
    assert(location.bankIndex == bank)
    guard let instruction: LR35902.Instruction = instructionMap[location] else {
      return
    }
    instructionMap[location] = nil

    clearCode(in: location..<(location + LR35902.InstructionSet.widths[instruction.spec]!.total))
  }

  // MARK: Clearing regions

  /** Removes all text-related information from the given range. */
  private func clearText(in range: Range<Cartridge.Location>) {
    text.remove(integersIn: range.asIntRange())
  }

  /** Removes all data-related information from the given range. */
  private func clearData(in range: Range<Cartridge.Location>) {
    let intRange = range.asIntRange()
    data.remove(integersIn: intRange)
    dataBlocks.remove(integersIn: intRange)
  }

  /**
   Removes all code-related information from the given range.

   Note that if an instruction footprint overlaps with the end of the given range then it is possible for some
   additional code to be cleared beyond the range.
   */
  private func clearCode(in range: Range<Cartridge.Location>) {
    let intRange = range.asIntRange()
    code.remove(integersIn: intRange)

    // Remove any labels, instructions, and transfers of control in this range.
    for location: Cartridge.Location in range.dropFirst() {
      deleteInstruction(at: location)
      transfers[location] = nil
      labelTypes[location] = nil
      bankChanges[location] = nil
    }

    // For any existing scope that intersects this range:
    // 1. Shorten it if it begins before the range.
    // 2. Delete it if it begins within the range.
    var mutatedScopes: Set<Range<Cartridge.Location>> = _contiguousScopes
    for scope: Range<Cartridge.Location> in _contiguousScopes {
      guard scope.overlaps(range) else {
        continue
      }
      mutatedScopes.remove(scope)
      if scope.lowerBound < range.lowerBound {
        mutatedScopes.insert(scope.lowerBound..<range.lowerBound)
      }
    }
    _contiguousScopes = mutatedScopes
  }
}
