import Foundation

extension Disassembler {
  public enum DataFormat {
    case bytes
    case image1bpp
    case image2bpp
    case jumpTable
  }

  /** Returns the format of the data at the given location, if any is known. */
  func formatOfData(at location: Cartridge.Location) -> DataFormat? {
    let index = location.index
    return dataFormats.first { (key: DataFormat, value: IndexSet) -> Bool in
      value.contains(index)
    }?.key
  }

  /** Registers that a specific location contains data. */
  func registerData(at location: Cartridge.Location) {
    registerData(at: location..<(location + 1))
  }

  /** Registers that a specific range contains data. */
  public func registerData(at range: Range<Cartridge.Location>, format: DataFormat = .bytes) {
    let intRange = range.asIntRange()
    for key in dataFormats.keys {
      dataFormats[key]?.remove(integersIn: intRange)
    }
    dataFormats[format, default: IndexSet()].insert(integersIn: intRange)
    registerRegion(range: range, as: .data)
  }
}
