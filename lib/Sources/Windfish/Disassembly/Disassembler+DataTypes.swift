import Foundation

extension Disassembler {
  public struct Datatype: Equatable {
    public let namedValues: [UInt8: String]
    public let interpretation: Interpretation
    public let representation: Representation

    public enum Interpretation {
      case any
      case enumerated
      case bitmask
    }

    public enum Representation: Int, Codable {
      case decimal
      case hexadecimal
      case binary
    }
  }

  /** Registers a new enumeration datatype. */
  public func createDatatype(named name: String, enumeration: [UInt8: String], representation: Datatype.Representation = .hexadecimal) {
    guard !name.isEmpty else {
      return
    }
    guard Set(enumeration.values).count == enumeration.count else {
      return  // There exists duplicate names
    }
    dataTypes[name] = Datatype(namedValues: enumeration, interpretation: .enumerated, representation: representation)
  }

  /** Registers a new bitmask datatype. */
  public func createDatatype(named name: String, bitmask: [UInt8: String], representation: Datatype.Representation = .binary) {
    guard !name.isEmpty else {
      return
    }
    guard Set(bitmask.values).count == bitmask.count else {
      return  // There exists duplicate names
    }
    dataTypes[name] = Datatype(namedValues: bitmask, interpretation: .bitmask, representation: representation)
  }

  /** Registers a new literal datatype. */
  public func registerDatatype(named name: String, representation: Datatype.Representation) {
    guard !name.isEmpty else {
      return
    }
    dataTypes[name] = Datatype(namedValues: [:], interpretation: .any, representation: representation)
  }

  /** Registers that a given instruction should use the given data type. */
  func registerDataType(at address: LR35902.Address, in bank: Cartridge.Bank, to type: String) {
    guard !type.isEmpty else {
      return
    }
    typeAtLocation[Cartridge.location(for: address, in: bank)!] = type
  }
}
