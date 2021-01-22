import Foundation

extension Disassembler {
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
    guard location.address < 0x8000 else {
      return .ram
    }
    let index = location.index
    if code.contains(index) {
      return .code
    }
    if data.contains(index) {
      switch formatOfData(at: location) {
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
    let _location = Cartridge._Location(truncatingIfNeeded: location.index)
    guard let instruction: LR35902.Instruction = instructionMap[_location] else {
      return
    }
    instructionMap[_location] = nil

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

    for key: DataFormat in dataFormats.keys {
      dataFormats[key]?.remove(integersIn: intRange)
    }
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
      labelNames[location] = nil
      labelTypes[location] = nil
      bankChanges[location] = nil
    }

    // For any existing scope that intersects this range:
    // 1. Shorten it if it begins before the range.
    // 2. Delete it if it begins within the range.
    if let overlappingScopes: Set<Range<Cartridge.Location>> = contiguousScopes[range.lowerBound.bank] {
      var mutatedScopes: Set<Range<Cartridge.Location>> = overlappingScopes
      for scope: Range<Cartridge.Location> in overlappingScopes {
        guard scope.overlaps(range) else {
          continue
        }
        mutatedScopes.remove(scope)
        if scope.lowerBound < range.lowerBound {
          mutatedScopes.insert(scope.lowerBound..<range.lowerBound)
        }
      }
      contiguousScopes[range.lowerBound.bank] = mutatedScopes
    }
  }
}
