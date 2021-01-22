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
  func registerRegion(range: Range<Int>, as category: RegionCategory) {
    switch category {
    case .code:
      code.insert(integersIn: range)

      clearData(in: range)
      clearText(in: range)

    case .data:
      data.insert(integersIn: range)
      if range.count > 1 {
        dataBlocks.insert(integersIn: (range.lowerBound + 1)..<range.upperBound)
      }

      clearCode(in: range)
      clearText(in: range)

    case .text:
      text.insert(integersIn: range)

      clearCode(in: range)
      clearData(in: range)
    }
  }

  /** Deletes an instruction from a specific location and clears any code-related information in its footprint. */
  func deleteInstruction(at location: Cartridge._Location) {
    guard let instruction: LR35902.Instruction = instructionMap[location] else {
      return
    }
    instructionMap[location] = nil

    let start: Int = Int(truncatingIfNeeded: location)
    let width: Int = Int(truncatingIfNeeded: LR35902.InstructionSet.widths[instruction.spec]!.total)
    clearCode(in: start..<(start + width))
  }

  // MARK: Clearing regions

  /** Removes all text-related information from the given range. */
  func clearText(in range: Range<Int>) {
    text.remove(integersIn: range)
  }

  /** Removes all data-related information from the given range. */
  func clearData(in range: Range<Int>) {
    data.remove(integersIn: range)
    dataBlocks.remove(integersIn: range)

    for key: DataFormat in dataFormats.keys {
      dataFormats[key]?.remove(integersIn: range)
    }
  }

  /**
   Removes all code-related information from the given range.

   Note that if an instruction footprint overlaps with the end of the given range then it is possible for some
   additional code to be cleared beyond the range.
   */
  func clearCode(in range: Range<Int>) {
    code.remove(integersIn: range)

    // Remove any labels, instructions, and transfers of control in this range.
    for intLocation: Int in range.dropFirst() {
      let location = Cartridge._Location(intLocation)
      deleteInstruction(at: location)
      transfers[location] = nil
      labelNames[location] = nil
      labelTypes[location] = nil
      bankChanges[Cartridge.Location(location: location)] = nil
    }

    let cartRange: Range<Cartridge._Location> = range.asCartridgeLocationRange()
    let addressAndBank = Cartridge.addressAndBank(from: cartRange.lowerBound)
    let effectiveBank = self.effectiveBank(at: addressAndBank.address, in: addressAndBank.bank)
    // For any existing scope that intersects this range:
    // 1. Shorten it if it begins before the range.
    // 2. Delete it if it begins within the range.
    if let overlappingScopes: Set<Range<Cartridge._Location>> = contiguousScopes[effectiveBank] {
      var mutatedScopes: Set<Range<Cartridge._Location>> = overlappingScopes
      for scope: Range<Cartridge._Location> in overlappingScopes {
        guard scope.overlaps(cartRange) else {
          continue
        }
        mutatedScopes.remove(scope)
        if scope.lowerBound < cartRange.lowerBound {
          mutatedScopes.insert(scope.lowerBound..<cartRange.lowerBound)
        }
      }
      contiguousScopes[addressAndBank.bank] = mutatedScopes
    }
  }
}
