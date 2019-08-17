import Foundation

import FixedWidthInteger

extension StringProtocol {
  fileprivate func trimmed() -> String {
    return self.trimmingCharacters(in: .whitespaces)
  }
}

private func codeAndComments(from line: String) -> (code: String?, comment: String?) {
  let parts = line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
  return (code: parts.first?.trimmed(), comment: parts.last?.trimmed())
}

private func opcodeAndOperands(from code: String) -> (opcode: String, operands: [String]) {
  let opcodeAndOperands = code.split(separator: " ", maxSplits: 1)

  let opcode = opcodeAndOperands[0].lowercased()
  let operands: [String]
  if opcodeAndOperands.count > 1 {
    operands = opcodeAndOperands[1].components(separatedBy: ",").map { $0.trimmed() }
  } else {
    operands = []
  }

  return (opcode: opcode, operands: operands)
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

      guard let code = codeAndComments(from: line).code, code.count > 0 else {
        return
      }

      let (opcode, operands) = opcodeAndOperands(from: code)

      guard let spec = RGBDSAssembler.representations[String(opcode)] else {
        return
      }

      print(spec)
//
//      if specs.count == 1 {
//        let spec = specs.first!
//        if spec.operandWidth == 0 {
//          guard operands.count == 0 else {
//            errors.append(Error(lineNumber: lineNumber, error: "Unexpected operand for \(opcode)"))
//            return
//          }
//
//          self.buffer.append(contentsOf: RGBDSAssembler.instructionOpcodeBinary[spec]!)
//
//        } else {
////            assertionFailure("Unhandled")
//        }
//
//      } else {
////          assertionFailure("Unhandled")
//      }
    }
    return errors
  }

  static var representations: [String: LR35902.InstructionSpec] = {
    var representations: [String: LR35902.InstructionSpec] = [:]
    LR35902.instructionTable.forEach { spec in
      representations[spec.representation] = spec
    }
    LR35902.instructionTableCB.forEach { spec in
      representations[spec.representation] = spec
    }
    return representations
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
