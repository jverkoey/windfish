import Foundation

public struct DisassemblyRequest<AddressType: BinaryInteger> {
  public init(data: Data) {
    self.data = data
  }

  // MARK: - Adding hints

  // MARK: Datatypes

  public enum DatatypeRepresentation {
    case decimal
    case hexadecimal
    case binary
  }

  public mutating func createDatatype(named name: String, enumeration: [UInt8: String], representation: DatatypeRepresentation = .hexadecimal) {
    precondition(Set(enumeration.values).count == enumeration.count, "There exist duplicate enumeration names.")
    createDatatype(named: name, type: Datatype(valueNames: enumeration, kind: .enumeration, representation: representation))
  }

  public mutating func createDatatype(named name: String, bitmask: [UInt8: String], representation: DatatypeRepresentation = .binary) {
    createDatatype(named: name, type: Datatype(valueNames: bitmask, kind: .bitmask, representation: representation))
  }

  public mutating func createDatatype(named name: String, representation: DatatypeRepresentation) {
    createDatatype(named: name, type: Datatype(valueNames: [:], kind: .any, representation: representation))
  }

  // MARK: Globals

  public mutating func addGlobals(_ globals: [AddressType: String]) {
    let globalValues: [AddressType: Global] = globals.mapValues {
      let global = Global(stringLiteral: $0)
      if let dataType = global.dataType, dataTypes[dataType] == nil {
        preconditionFailure("\(dataType) is not a registered data type.")
      }
      return global
    }
    self.globals.merge(globalValues) { (global1, global2) in
      preconditionFailure("\(global1.name) would be overwritten by \(global2.name).")
    }
  }

  public mutating func addGlobal(at address: AddressType, named name: String) {
    addGlobals([address: name])
  }

  // MARK: - Converting to wire format

  public func toWireformat() throws -> Data {
    return try Disassembly_Request.with { request in
      request.binary = data
      request.hints = Disassembly_Hints.with { hints in

        hints.datatypes = dataTypes.map { name, datatype in
          Disassembly_Datatype.with { proto in
            proto.name = name

            switch datatype.kind {
            case .enumeration:
              proto.kind = .enumeration
            case .bitmask:
              proto.kind = .bitmask
            case .any:
              proto.kind = .any
            }

            switch datatype.representation {
            case .binary:
              proto.representation = .binary
            case .decimal:
              proto.representation = .decimal
            case .hexadecimal:
              proto.representation = .hexadecimal
            }

            proto.valueNames = datatype.valueNames.reduce(into: [:]) { (accumulator, element) in
              accumulator[UInt64(element.key)] = element.value
            }
          }
        }

        hints.globals = globals.map { address, global in
          Disassembly_Global.with { proto in
            proto.address = UInt64(address)
            proto.name = global.name
            if let dataType = global.dataType {
              proto.datatype = dataType
            }
          }
        }

      }
    }.serializedData()
  }

  private let data: Data
  private var globals: [AddressType: Global] = [:]
  private var dataTypes: [String: Datatype] = [:]

  private enum DatatypeKind {
    case enumeration
    case bitmask
    case any
  }

  private struct Datatype {
    let valueNames: [UInt8: String]
    let kind: DatatypeKind
    let representation: DatatypeRepresentation
  }

  private mutating func createDatatype(named name: String, type: Datatype) {
    precondition(!name.isEmpty, "Data type has invalid name.")
    precondition(dataTypes[name] == nil, "Data type \(name) already exists.")
    dataTypes[name] = type
  }
}
