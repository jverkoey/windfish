import Foundation

import CPU
import FoundationExtensions
import RGBDS

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

  public static func specs(for code: String) -> (RGBDS.Statement, [LR35902.Instruction.Spec])? {
    let statement = RGBDS.Statement(fromLine: code)!
    let representation = statement.tokenizedString
    guard let specs = LR35902.InstructionSet.tokenStringToSpecs[representation] else {
      return nil
    }

    return (statement, specs)
  }

  public static func codeAndComments(from line: String) -> (code: String?, comment: String?) {
    let parts = line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
    return (code: parts.first?.trimmed(), comment: parts.last?.trimmed())
  }

  public static func instruction(from statement: RGBDS.Statement, using spec: LR35902.Instruction.Spec) throws -> LR35902.Instruction? {
    if case LR35902.Instruction.Spec.stop = spec {
      return .init(spec: spec, immediate: .imm8(0))
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
      let value = statement.operands[index]
      switch child.value {
      case let restartAddress as LR35902.Instruction.RestartAddress:
        let numericValue: UInt16 = try cast(string: value, negativeType: Int16.self)
        if numericValue != restartAddress.rawValue {
          return nil
        }
      case let bit as LR35902.Instruction.Bit:
        let numericValue: UInt16 = try cast(string: value, negativeType: Int16.self)
        if numericValue != bit.rawValue {
          return nil
        }
      case LR35902.Instruction.Numeric.imm16:
        let numericValue: UInt16 = try cast(string: value, negativeType: Int16.self)
        return .init(spec: spec, immediate: .imm16(numericValue))
      case LR35902.Instruction.Numeric.imm8, LR35902.Instruction.Numeric.simm8:
        var numericValue: UInt8 = try cast(string: value, negativeType: Int8.self)
        if case .jr = spec {
          // Relative jumps in assembly are written from the point of view of the instruction's beginning.
          numericValue = numericValue.subtractingReportingOverflow(UInt8(LR35902.InstructionSet.widths[spec]!.total)).partialValue
        }
        return .init(spec: spec, immediate: .imm8(numericValue))
      case LR35902.Instruction.Numeric.ffimm8addr:
        let numericValue: UInt16 = try cast(string: String(value.dropFirst().dropLast().trimmed()), negativeType: Int16.self)
        if (numericValue & 0xFF00) != 0xFF00 {
          return nil
        }
        let lowerByteValue = UInt8(numericValue & 0xFF)
        return .init(spec: spec, immediate: .imm8(lowerByteValue))
      case LR35902.Instruction.Numeric.sp_plus_simm8:
        let numericValue: UInt8 = try cast(string: String(value.dropFirst(3).trimmed()), negativeType: Int8.self)
        return .init(spec: spec, immediate: .imm8(numericValue))
      case LR35902.Instruction.Numeric.imm16addr:
        let numericValue: UInt16 = try cast(string: String(value.dropFirst().dropLast().trimmed()), negativeType: Int16.self)
        return .init(spec: spec, immediate: .imm16(numericValue))
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
          LR35902.InstructionSet.widths[pair1.spec]!.total < LR35902.InstructionSet.widths[pair2.spec]!.total
        })[0]

        self.instructions.append(shortestInstruction)

        self.buffer.append(contentsOf: LR35902.InstructionSet.data(for: shortestInstruction.spec)!)
        switch shortestInstruction.immediate {
        case let .imm8(immediate):
          self.buffer.append(contentsOf: [immediate])
        case var .imm16(immediate):
          withUnsafeBytes(of: &immediate) { buffer in
            self.buffer.append(contentsOf: Data(buffer))
          }
        case .none:
          break
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
}
