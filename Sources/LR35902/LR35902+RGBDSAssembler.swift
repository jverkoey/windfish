import Foundation

import FixedWidthInteger

public final class RGBDSAssembler {

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

  static func assemble(assembly: String) -> Data {
    var buffer = Data()
    assembly.enumerateLines { (line, stop) in
      let lineContent = line.trimmingCharacters(in: .whitespaces)
      let lineParts = lineContent.split(separator: " ")

      // If we're an opcode...
      let opcode = lineParts.first!.lowercased()
      if let specs = instructionOpcodeAssembly[String(opcode)] {
        if specs.count == 1 {
          let spec = specs.first!
          if spec.operandWidth == 0 {
            buffer.append(contentsOf: instructionOpcodeBinary[spec]!)
          }
        }
      }
    }

    return buffer
  }
}
