import Foundation

import RGBDS

extension Project {
  public final class DataType: NSObject {
    public init(name: String, representation: String, interpretation: String, mappings: [Mapping]) {
      self.name = name
      self.representation = representation
      self.interpretation = interpretation
      self.mappings = mappings
    }

    public struct Interpretation {
      public static let any = "Any"
      public static let enumerated = "Enumerated"
      public static let bitmask = "Bitmask"
    }
    public struct Representation {
      public static let decimal = "Decimal"
      public static let hexadecimal = "Hex"
      public static let binary = "Binary"
    }

    public final class Mapping: NSObject, Codable {
      public init(name: String, value: UInt8) {
        self.name = name
        self.value = value
      }

      public var name: String
      public var value: UInt8
    }

    public var name: String
    public var representation: String
    public var interpretation: String
    public var mappings: [Mapping]
  }

  static public func loadDataTypes(from data: Data) -> [DataType] {
    guard let dataTypesText = String(data: data, encoding: .utf8) else {
      return []
    }
    var dataTypes: [DataType] = []

    var dataType = DataType(name: "", representation: "", interpretation: "", mappings: [])

    dataTypesText.enumerateLines { line, _ in
      let trimmedLine = line.trimmed()
      if trimmedLine.isEmpty {
        if !dataType.name.isEmpty {
          dataTypes.append(dataType)
        }
        dataType = DataType(name: "", representation: "", interpretation: "", mappings: [])
        return
      }
      if trimmedLine.starts(with: ";") {
        // New data type definition
        let scanner = Scanner(string: trimmedLine)
        _ = scanner.scanString(";")
        dataType.name = scanner.scanUpToString("[")!.trimmed()
        _ = scanner.scanString("[")
        dataType.interpretation = scanner.scanUpToString("]")!.trimmed()
        _ = scanner.scanString("]")
        _ = scanner.scanUpToString("[")
        _ = scanner.scanString("[")
        dataType.representation = scanner.scanUpToString("]")!.trimmed()
        return
      }
      let codeAndComments = line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
      let code = codeAndComments[0]
      if !code.contains(" EQU ") {
        return
      }
      let definitionParts = code.components(separatedBy: " EQU ")
      let name = definitionParts[0].trimmed()
      let valueText = definitionParts[1].trimmed()
      let value: UInt8
      if valueText.starts(with: RGBDS.NumericPrefix.hexadecimal) {
        value = UInt8(valueText.dropFirst(), radix: 16)!
      } else if valueText.starts(with: RGBDS.NumericPrefix.binary) {
        value = UInt8(valueText.dropFirst(), radix: 2)!
      } else {
        value = UInt8(valueText)!
      }
      dataType.mappings.append(DataType.Mapping(name: name, value: value))
    }
    if !dataType.name.isEmpty {
      dataTypes.append(dataType)
    }
    return dataTypes
  }

  public func dataTypesAsData() -> Data {
    return dataTypes
      .sorted(by: { $0.name < $1.name })
      .map { (dataType: DataType) -> String in
        (["; \(dataType.name) [\(dataType.interpretation)] [\(dataType.representation)]"]
          + dataType.mappings.map { (mapping: DataType.Mapping) -> String in
            switch dataType.representation {
            case DataType.Representation.binary:
              return "\(mapping.name) EQU \(RGBDS.asBinaryString(mapping.value))"
            case DataType.Representation.hexadecimal:
              return "\(mapping.name) EQU \(RGBDS.asHexString(mapping.value))"
            case DataType.Representation.decimal:
              return "\(mapping.name) EQU \(mapping.value)"
            default:
              fatalError()
            }
          }).joined(separator: "\n")
      }
      .joined(separator: "\n\n")
      .data(using: .utf8) ?? Data()
  }

  func applyDataTypes(to configuration: Disassembler.MutableConfiguration) {
    for dataType: DataType in dataTypes {
      let mappingDict: [UInt8: String] = dataType.mappings.reduce(into: [:]) { accumulator, mapping in
        accumulator[mapping.value] = mapping.name
      }
      let representation: Disassembler.MutableConfiguration.Datatype.Representation
      switch dataType.representation {
      case DataType.Representation.binary:
        representation = .binary
      case DataType.Representation.decimal:
        representation = .decimal
      case DataType.Representation.hexadecimal:
        representation = .hexadecimal
      default:
        preconditionFailure()
      }
      switch dataType.interpretation {
      case DataType.Interpretation.any:
        configuration.registerDatatype(named: dataType.name, representation: representation)
      case DataType.Interpretation.bitmask:
        configuration.createDatatype(named: dataType.name, bitmask: mappingDict, representation: representation)
      case DataType.Interpretation.enumerated:
        configuration.createDatatype(named: dataType.name, enumeration: mappingDict, representation: representation)
      default:
        preconditionFailure()
      }
    }
  }
}
