import Foundation
import RGBDS

extension Disassembler {
  private typealias DatatypeElement = Dictionary<String, Configuration.Datatype>.Element

  func createDataTypesSource() -> Source.FileDescription? {
    let dataTypes = configuration.allDatatypes()
    guard !dataTypes.isEmpty else {
      return nil
    }
    var asm: String = String()

    for dataType: DatatypeElement in dataTypes.sorted(by: { $0.key < $1.key }) {
      guard !dataType.value.namedValues.isEmpty else {
        // No need to write out datatypes with no named values.
        continue
      }
      asm += "; Type: \(dataType.key)\n"
      let namedValues: [Dictionary<UInt8, String>.Element] = dataType.value.namedValues.sorted(by: { $0.key < $1.key })
      guard let longestVariable: Int = namedValues.map({ $0.value.count }).max() else {
        continue
      }
      asm += namedValues.map {
        let name: String = $0.value.padding(toLength: longestVariable, withPad: " ", startingAt: 0)
        let value: String
        switch dataType.value.representation {
        case .binary:      value = RGBDS.asBinaryString($0.key)
        case .decimal:     value = RGBDS.asDecimalString($0.key)
        case .hexadecimal: value = RGBDS.asHexString($0.key)
        }
        return "\(name) EQU \(value)"
      }.joined(separator: "\n")
      asm += "\n\n"
    }
    return .datatypes(content: asm)
  }
}
