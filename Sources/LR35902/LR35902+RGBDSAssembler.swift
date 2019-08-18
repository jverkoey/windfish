import Foundation

import FixedWidthInteger

private func codeAndComments(from line: String) -> (code: String?, comment: String?) {
  let parts = line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
  return (code: parts.first?.trimmed(), comment: parts.last?.trimmed())
}

private func createStatement(from code: String) -> RGBDSAssembly.Statement {
  let opcodeAndOperands = code.split(separator: " ", maxSplits: 1)

  let opcode = opcodeAndOperands[0].lowercased()

  if opcodeAndOperands.count > 1 {
    let operands: [String] = opcodeAndOperands[1].components(separatedBy: ",").map { $0.trimmed() }
    return RGBDSAssembly.Statement(opcode: opcode, operands: operands)
  } else {
    return RGBDSAssembly.Statement(opcode: opcode)
  }
}

private func isNumber(_ string: String) -> Bool {
  return string.hasPrefix("$") || string.hasPrefix("0x") || Int(string) != nil
}

private func createRepresentation(from statement: RGBDSAssembly.Statement) -> String {
  if let operands: [String] = statement.operands?.map({ operand in
    if isNumber(operand) {
      return "#"
    } else if operand.hasPrefix("[") && operand.hasSuffix("]") && isNumber(String(operand.dropFirst().dropLast())) {
      return "[#]"
    } else if operand.hasPrefix("sp+") {
      return "sp+#"
    }
    return operand
  }) {
    return "\(statement.opcode) \(operands.joined(separator: ", "))"
  } else {
    return statement.opcode
  }
}

private func cast<T: UnsignedInteger, negT: SignedInteger>(string: String, negativeType: negT.Type)
  throws -> T
  where T: FixedWidthInteger, negT: FixedWidthInteger, T: BitPatternInitializable, T.CompanionType == negT {
  var value = string
  let isNegative = value.starts(with: "-")
  if isNegative {
    value = String(value.dropFirst(1))
  }

  var numericPart: String
  var radix: Int
  if value.starts(with: "$") {
    numericPart = String(value.dropFirst())
    radix = 16
  } else if value.starts(with: "0x") {
    numericPart = String(value.dropFirst(2))
    radix = 16
  } else {
    numericPart = value
    radix = 10
  }

  if isNegative {
    guard let negativeValue = negT(numericPart, radix: radix) else {
      throw RGBDSAssembler.Error(lineNumber: nil, error: "Unable to represent \(value) as a UInt16")
    }
    return T(bitPattern: -negativeValue)
  } else if let numericValue = T(numericPart, radix: radix) {
    return numericValue
  }

  throw RGBDSAssembler.Error(lineNumber: nil, error: "Unable to represent \(value) as a UInt16")
}

private func extractOperandsAsBinary(from statement: RGBDSAssembly.Statement, using spec: LR35902.InstructionSpec) throws -> [UInt8]? {
  if case LR35902.InstructionSpec.stop = spec {
    return [0x00]
  }
  guard let operands = Mirror(reflecting: spec).children.first else {
    return []
  }
  if let subSpec = operands.value as? LR35902.InstructionSpec {
    return try extractOperandsAsBinary(from: statement, using: subSpec)
  }
  var binaryOperands: [UInt8] = []

  let children: Mirror.Children
  let reflectedChildren = Mirror(reflecting: operands.value).children
  if reflectedChildren.count > 0 {
    children = reflectedChildren
  } else {
    children = Mirror.Children([(label: nil, value: operands.value)])
  }
  var index = 0
  for child in children {
    // Any isn't nullable, even though it might represent a null value (e.g. a .jr(nil, .immediate8) spec with an
    // optional first argument), so we need to use Optional<Any>.none to represent an optional argument in this case.
    if case Optional<Any>.none = child.value {
      continue
    }
    defer {
      index += 1
    }
    switch child.value {
    case let restartAddress as LR35902.RestartAddress:
      if let value = Mirror(reflecting: statement).descendant(1, 0, index) as? String {
        let numericValue: UInt16 = try cast(string: value, negativeType: Int16.self)
        if numericValue != restartAddress.rawValue {
          return nil
        }
      }
    case let bit as LR35902.Bit:
      if let value = Mirror(reflecting: statement).descendant(1, 0, index) as? String {
        let numericValue: UInt16 = try cast(string: value, negativeType: Int16.self)
        if numericValue != bit.rawValue {
          return nil
        }
      }
    case LR35902.Operand.immediate16:
      if let value = Mirror(reflecting: statement).descendant(1, 0, index) as? String {
        var numericValue: UInt16 = try cast(string: value, negativeType: Int16.self)
        withUnsafeBytes(of: &numericValue) { buffer in
          binaryOperands.append(contentsOf: Data(buffer))
        }
      }
    case LR35902.Operand.immediate8, LR35902.Operand.immediate8signed:
      if let value = Mirror(reflecting: statement).descendant(1, 0, index) as? String {
        var numericValue: UInt8 = try cast(string: value, negativeType: Int8.self)
        if case .jr = spec {
          // Relative jumps in assembly are written from the point of view of the instruction's beginning.
          numericValue = numericValue.subtractingReportingOverflow(UInt8(LR35902.instructionWidths[spec]!)).partialValue
        }
        withUnsafeBytes(of: &numericValue) { buffer in
          binaryOperands.append(contentsOf: Data(buffer))
        }
      }
    case LR35902.Operand.ffimmediate8Address:
      if let value = Mirror(reflecting: statement).descendant(1, 0, index) as? String {
        let numericValue: UInt16 = try cast(string: String(value.dropFirst().dropLast().trimmed()), negativeType: Int16.self)
        if (numericValue & 0xFF00) != 0xFF00 {
          return nil
        }
        var lowerByteValue = UInt8(numericValue & 0xFF)
        withUnsafeBytes(of: &lowerByteValue) { buffer in
          binaryOperands.append(contentsOf: Data(buffer))
        }
      }
    case LR35902.Operand.spPlusImmediate8Signed:
      if let value = Mirror(reflecting: statement).descendant(1, 0, index) as? String {
        var numericValue: UInt8 = try cast(string: String(value.dropFirst(3).trimmed()), negativeType: Int8.self)
        withUnsafeBytes(of: &numericValue) { buffer in
          binaryOperands.append(contentsOf: Data(buffer))
        }
      }
    case LR35902.Operand.immediate16address:
      if let value = Mirror(reflecting: statement).descendant(1, 0, index) as? String {
        var numericValue: UInt16 = try cast(string: String(value.dropFirst().dropLast().trimmed()), negativeType: Int16.self)
        withUnsafeBytes(of: &numericValue) { buffer in
          binaryOperands.append(contentsOf: Data(buffer))
        }
      }
    default:
      break
    }
  }
  return binaryOperands
}

public final class RGBDSAssembler {

  public init() {
  }

  public var buffer = Data()

  public struct Error: Swift.Error, Equatable {
    let lineNumber: Int?
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

      let statement = createStatement(from: code)
      let representation = createRepresentation(from: statement)

      guard let specs = RGBDSAssembler.representations[representation] else {
        errors.append(Error(lineNumber: lineNumber, error: "Invalid instruction: \(code)"))
        return
      }

      do {

        let spec: LR35902.InstructionSpec
        let operandsAsBinary: [UInt8]
        if specs.count > 1 {
          let specsAndBinary: [(LR35902.InstructionSpec, [UInt8])] = try zip(specs, specs.map({ spec in
            try extractOperandsAsBinary(from: statement, using: spec)
          })).compactMap { result in
            if let binary = result.1 {
              return (result.0, binary)
            } else {
              return nil
            }
          }
          if specsAndBinary.count == 0 {
            throw Error(lineNumber: lineNumber, error: "No valid instruction found for \(code)")
          }
          (spec, operandsAsBinary) = specsAndBinary.sorted(by: { pair1, pair2 in
            pair1.1.count < pair2.1.count
          })[0]
        } else {
          spec = specs[0]
          operandsAsBinary = try extractOperandsAsBinary(from: statement, using: spec)!
        }

        self.buffer.append(contentsOf: RGBDSAssembler.instructionOpcodeBinary[spec]!)
        self.buffer.append(contentsOf: operandsAsBinary)

      } catch let error as RGBDSAssembler.Error {
        if error.lineNumber == nil {
          errors.append(.init(lineNumber: lineNumber, error: error.error))
        } else {
          errors.append(error)
        }
        return
      } catch {
        return
      }
    }
    return errors
  }

  static var representations: [String: [LR35902.InstructionSpec]] = {
    var representations: [String: [LR35902.InstructionSpec]] = [:]
    LR35902.instructionTable.forEach { spec in
      if case .invalid = spec {
        return
      }
      representations[spec.representation, default: []].append(spec)
    }
    LR35902.instructionTableCB.forEach { spec in
      if case .invalid = spec {
        return
      }
      representations[spec.representation, default: []].append(spec)
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
