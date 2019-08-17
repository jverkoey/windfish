import Foundation

import FixedWidthInteger

private func codeAndComments(from line: String) -> (code: String?, comment: String?) {
  let parts = line.components(separatedBy: ";")
  return (code: parts[0], comment: parts[1...].joined(separator: ";"))
}

public final class RGBDSAssembler {

  public init() {
  }

  public var buffer = Data()

  public struct Error: Equatable {
    let lineNumber: Int
    let error: String
  }

  public func assemble(assembly: String) -> [Error] {
    var lineNumber = 1
    var errors: [Error] = []

    assembly.enumerateLines { (line, stop) in
      defer {
        lineNumber += 1
      }

      let lineContent = line.trimmingCharacters(in: .whitespaces)
      let code = codeAndComments(from: lineContent).code

      // If we're an opcode...
      if let codeParts = code?.components(separatedBy: " ") {
        if let opcode = codeParts.first?.lowercased(),
          let specs = RGBDSAssembler.instructionOpcodeAssembly[String(opcode)] {
          if specs.count == 1 {
            let spec = specs.first!
            if spec.operandWidth == 0 {
              if codeParts.count > 1 {
                errors.append(Error(lineNumber: lineNumber, error: "Unexpected operand for \(opcode)"))
              } else {
                self.buffer.append(contentsOf: RGBDSAssembler.instructionOpcodeBinary[spec]!)
              }
            }
          }
        }
      }
    }
    return errors
  }

  static var instructionOpcodeAssembly: [String: [LR35902.InstructionSpec]] = {
    var assembly: [String: [LR35902.InstructionSpec]] = [:]
    LR35902.instructionTable.forEach { spec in
      assembly[spec.opcode, default: []].append(spec)
    }
    LR35902.instructionTableCB.forEach { spec in
      assembly[spec.opcode, default: []].append(spec)
    }
    return assembly
  }()

  static var instructionOpcodeBinary: [LR35902.InstructionSpec: [UInt8]] = {
    var binary: [LR35902.InstructionSpec: [UInt8]] = [:]
    for (byteRepresentation, spec) in LR35902.instructionTable.enumerated() {
      binary[spec] = [UInt8(byteRepresentation)]
    }
    for (byteRepresentation, spec) in LR35902.instructionTableCB.enumerated() {
      binary[spec] = [0xCB, UInt8(byteRepresentation)]
    }
    return binary
  }()

}
