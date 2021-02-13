import Foundation

import RGBDS

extension Project {
  final class DataType: NSObject {
    init(name: String, representation: String, interpretation: String, mappings: [Mapping]) {
      self.name = name
      self.representation = representation
      self.interpretation = interpretation
      self.mappings = mappings
    }

    struct Interpretation {
      static let any = "Any"
      static let enumerated = "Enumerated"
      static let bitmask = "Bitmask"
    }
    struct Representation {
      static let decimal = "Decimal"
      static let hexadecimal = "Hex"
      static let binary = "Binary"
    }

    final class Mapping: NSObject, Codable {
      init(name: String, value: UInt8) {
        self.name = name
        self.value = value
      }

      var name: String
      var value: UInt8
    }

    var name: String
    var representation: String
    var interpretation: String
    var mappings: [Mapping]
  }


  static func loadDataTypes(from url: URL) -> [DataType] {
    guard let dataTypesText = try? String(contentsOf: url, encoding: .utf8) else {
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
