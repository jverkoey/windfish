import Foundation

import CPU
import FixedWidthInteger

public protocol InstructionSpecRepresentable {
  /**
   The assembly opcode for this instruction.
   */
  var opcode: String { get }

  /**
   An abstract representation of this instruction in assembly.

   The following wildcards are permitted:

   - #: Any numeric value.
   */
  var representation: String { get }
}

/**
 An abstract representation of an instruction's operand.
 */
public protocol InstructionOperandAssemblyRepresentable {
  /**
   The operand's abstract representation.
   */
  var representation: InstructionOperandAssemblyRepresentation { get }
}

/**
 Possible types of abstract representations for instruction operands.
 */
public enum InstructionOperandAssemblyRepresentation {
  /**
   A numeric representation.
   */
  case numeric

  /**
   An address representation.
   */
  case address

  /**
   An FF## address representation.
   */
  case ffaddress

  /**
   A stack pointer offset representation.
   */
  case stackPointerOffset

  /**
   A specific representation.
   */
  case specific(String)
}

extension InstructionSpec {
  /**
   Extracts the opcode from the name of the first part of the spec.
   */
  public var opcode: String {
    if let child = Mirror(reflecting: self).children.first {
      if let childInstruction = child.value as? Self {
        return childInstruction.opcode
      }
      return child.label!
    } else {
      return "\("\(self)".split(separator: ".").last!)"
    }
  }
}

extension InstructionSpec {
  /**
   Returns a generic representation of the instruction by visiting each of the operands and returning their representable versions.
   */
  public var representation: String {
    var operands: [String] = []
    visit { operand in
      // Optional operands are provided by the visitor as boxed optional types represented as an Any.
      // We can't cast an Any to an Any? using the as? operator, so perform an explicit Optional-type unboxing instead:
      guard let valueUnboxed = operand?.value,
            case Optional<Any>.some(let value) = valueUnboxed else {
        return
      }

      if let representable = value as? InstructionOperandAssemblyRepresentable {
        switch representable.representation {
        case .numeric:
          operands.append("#")
        case .address:
          operands.append("[#]")
        case .ffaddress:
          operands.append("[ff#]")
        case .stackPointerOffset:
          operands.append("sp+#")
        case let .specific(string):
          operands.append(string)
        }
      } else {
        operands.append("\(value)")
      }
    }
    var representationParts = [opcode]
    if !operands.isEmpty {
      representationParts.append(operands.joined(separator: ", "))
    }
    return representationParts.joined(separator: " ")
  }
}

extension LR35902.Instruction.Spec: InstructionSpecRepresentable {
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
  return string.hasPrefix("$") || string.hasPrefix("0x") || string.hasPrefix("%") || string.hasPrefix("#") || Int(string) != nil
}

private func createRepresentation(from statement: RGBDSAssembly.Statement) -> String {
  if let operands: [String] = statement.operands?.map({ operand in
    if isNumber(operand) {
      return "#"
    } else if operand.hasPrefix("[") && operand.hasSuffix("]") && String(operand.dropFirst().dropLast()).lowercased().hasPrefix("$ff") {
      return "[ff#]"
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
  } else if value.starts(with: "%") {
    numericPart = String(value.dropFirst())
    radix = 2
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

public final class RGBDSAssembler {

  public init() {
  }

  public var buffer = Data()

  // TODO: Allow comments to be represented in the assembly as well for use in macros.
  // This will need to become an enum of comments, newlines, or instructions.
  public var instructions: [LR35902.Instruction] = []

  public struct Error: Swift.Error, Equatable {
    let lineNumber: Int?
    let error: String
  }

  public static func specs(for code: String) -> (RGBDSAssembly.Statement, [LR35902.Instruction.Spec])? {
    let statement = createStatement(from: code)
    let representation = createRepresentation(from: statement)
    guard let specs = RGBDSAssembler.representations[representation] else {
      return nil
    }

    return (statement, specs)
  }

  public static func codeAndComments(from line: String) -> (code: String?, comment: String?) {
    let parts = line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
    return (code: parts.first?.trimmed(), comment: parts.last?.trimmed())
  }

  public static func instruction(from statement: RGBDSAssembly.Statement, using spec: LR35902.Instruction.Spec) throws -> LR35902.Instruction? {
    if case LR35902.Instruction.Spec.stop = spec {
      return .init(spec: spec, imm8: 0)
    }
    guard var operands = Mirror(reflecting: spec).children.first else {
      return .init(spec: spec)
    }
    while let subSpec = operands.value as? LR35902.Instruction.Spec {
      guard let subOperands = Mirror(reflecting: subSpec).children.first else {
        return .init(spec: spec)
      }
      operands = subOperands
    }

    let children: Mirror.Children
    let reflectedChildren = Mirror(reflecting: operands.value).children
    if reflectedChildren.count > 0 {
      children = reflectedChildren
    } else {
      children = Mirror.Children([(label: nil, value: operands.value)])
    }
    var index = 0
    for child in children {
      // Any isn't nullable, even though it might represent a null value (e.g. a .jr(nil, .imm8) spec with an
      // optional first argument), so we need to use Optional<Any>.none to represent an optional argument in this case.
      if case Optional<Any>.none = child.value {
        continue
      }
      defer {
        index += 1
      }
      switch child.value {
      case let restartAddress as LR35902.Instruction.RestartAddress:
        if let value = Mirror(reflecting: statement).descendant(1, 0, index) as? String {
          let numericValue: UInt16 = try cast(string: value, negativeType: Int16.self)
          if numericValue != restartAddress.rawValue {
            return nil
          }
        }
      case let bit as LR35902.Instruction.Bit:
        if let value = Mirror(reflecting: statement).descendant(1, 0, index) as? String {
          let numericValue: UInt16 = try cast(string: value, negativeType: Int16.self)
          if numericValue != bit.rawValue {
            return nil
          }
        }
      case LR35902.Instruction.Numeric.imm16:
        if let value = Mirror(reflecting: statement).descendant(1, 0, index) as? String {
          let numericValue: UInt16 = try cast(string: value, negativeType: Int16.self)
          return .init(spec: spec, imm16: numericValue)
        }
      case LR35902.Instruction.Numeric.imm8, LR35902.Instruction.Numeric.simm8:
        if let value = Mirror(reflecting: statement).descendant(1, 0, index) as? String {
          var numericValue: UInt8 = try cast(string: value, negativeType: Int8.self)
          if case .jr = spec {
            // Relative jumps in assembly are written from the point of view of the instruction's beginning.
            numericValue = numericValue.subtractingReportingOverflow(UInt8(LR35902.Instruction.widths[spec]!.total)).partialValue
          }
          return .init(spec: spec, imm8: numericValue)
        }
      case LR35902.Instruction.Numeric.ffimm8addr:
        if let value = Mirror(reflecting: statement).descendant(1, 0, index) as? String {
          let numericValue: UInt16 = try cast(string: String(value.dropFirst().dropLast().trimmed()), negativeType: Int16.self)
          if (numericValue & 0xFF00) != 0xFF00 {
            return nil
          }
          let lowerByteValue = UInt8(numericValue & 0xFF)
          return .init(spec: spec, imm8: lowerByteValue)
        }
      case LR35902.Instruction.Numeric.sp_plus_simm8:
        if let value = Mirror(reflecting: statement).descendant(1, 0, index) as? String {
          let numericValue: UInt8 = try cast(string: String(value.dropFirst(3).trimmed()), negativeType: Int8.self)
          return .init(spec: spec, imm8: numericValue)
        }
      case LR35902.Instruction.Numeric.imm16addr:
        if let value = Mirror(reflecting: statement).descendant(1, 0, index) as? String {
          let numericValue: UInt16 = try cast(string: String(value.dropFirst().dropLast().trimmed()), negativeType: Int16.self)
          return .init(spec: spec, imm16: numericValue)
        }
      default:
        break
      }
    }
    return .init(spec: spec)
  }

  // TODO: Allow generation of list of instructions instead of just data.
  public func assemble(assembly: String) -> [Error] {
    var lineNumber = 1
    var errors: [Error] = []

    assembly.enumerateLines { (line, stop) in
      defer {
        lineNumber += 1
      }

      guard let code = RGBDSAssembler.codeAndComments(from: line).code, code.count > 0 else {
        return
      }

      guard let (statement, specs) = RGBDSAssembler.specs(for: code) else {
        errors.append(Error(lineNumber: lineNumber, error: "Invalid instruction: \(line)"))
        return
      }

      do {
        let instructions: [LR35902.Instruction] = try specs.compactMap { spec in
          try RGBDSAssembler.instruction(from: statement, using: spec)
        }
        guard instructions.count > 0 else {
          throw Error(lineNumber: lineNumber, error: "No valid instruction found for \(line)")
        }
        let shortestInstruction = instructions.sorted(by: { pair1, pair2 in
          pair1.spec.instructionWidth < pair2.spec.instructionWidth
        })[0]

        self.instructions.append(shortestInstruction)

        self.buffer.append(contentsOf: RGBDSAssembler.instructionOpcodeBinary[shortestInstruction.spec]!)
        if let imm8 = shortestInstruction.imm8 {
          self.buffer.append(contentsOf: [imm8])
        } else if var imm16 = shortestInstruction.imm16 {
          withUnsafeBytes(of: &imm16) { buffer in
            self.buffer.append(contentsOf: Data(buffer))
          }
        }

      } catch let error as RGBDSAssembler.Error {
        if error.lineNumber == nil {
          errors.append(.init(lineNumber: lineNumber, error: error.error))
        } else {
          errors.append(error)
        }
      } catch {
      }
    }
    return errors
  }

  static var representations: [String: [LR35902.Instruction.Spec]] = {
    var representations: [String: [LR35902.Instruction.Spec]] = [:]
    LR35902.Instruction.table.forEach { spec in
      if case .invalid = spec {
        return
      }
      representations[spec.representation, default: []].append(spec)
    }
    LR35902.Instruction.tableCB.forEach { spec in
      if case .invalid = spec {
        return
      }
      representations[spec.representation, default: []].append(spec)
    }
    return representations
  }()

  static var instructionOpcodeBinary: [LR35902.Instruction.Spec: [UInt8]] = {
    var binary: [LR35902.Instruction.Spec: [UInt8]] = [:]
    for (byteRepresentation, spec) in LR35902.Instruction.table.enumerated() {
      binary[spec] = [UInt8(byteRepresentation)]
    }
    for (byteRepresentation, spec) in LR35902.Instruction.tableCB.enumerated() {
      binary[spec] = [0xCB, UInt8(byteRepresentation)]
    }
    return binary
  }()

}
