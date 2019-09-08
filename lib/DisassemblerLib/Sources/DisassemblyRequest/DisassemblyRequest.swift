import Foundation
import CPU

public final class DisassemblyRequest<AddressType: BinaryInteger, InstructionType: Instruction> {
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

  public func createDatatype(named name: String, representation: DatatypeRepresentation = .hexadecimal, enumeration: [UInt8: String]) {
    precondition(Set(enumeration.values).count == enumeration.count, "There exist duplicate enumeration names.")
    createDatatype(named: name, type: Datatype(valueNames: enumeration, kind: .enumeration, representation: representation))
  }

  public func createDatatype(named name: String, representation: DatatypeRepresentation = .binary, bitmask: [UInt8: String]) {
    createDatatype(named: name, type: Datatype(valueNames: bitmask, kind: .bitmask, representation: representation))
  }

  public func createDatatype(named name: String, representation: DatatypeRepresentation) {
    createDatatype(named: name, type: Datatype(valueNames: [:], kind: .any, representation: representation))
  }

  // MARK: Globals

  public func addGlobals(_ globals: [AddressType: String]) {
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

  public func addGlobal(at address: AddressType, named name: String) {
    addGlobals([address: name])
  }

  // MARK: Macros

  public enum MacroPattern: Hashable {
    case any(InstructionType.SpecType, argument: UInt64? = nil, argumentText: String? = nil)
    case instruction(InstructionType)
  }
  public func createMacro(named name: String, pattern: [MacroPattern],
                          validArgumentValues: [Int: IndexSet]? = nil) {
    // TODO: Validate the pattern.
    macros[name] = Macro(patterns: pattern, validArgumentValues: validArgumentValues)
  }

  // MARK: - Converting to wire format

  public func toWireformat() throws -> Data {
    return try Disassembly_Request.with { request in
      request.binary = data
      request.hints = Disassembly_Hints.with { hints in

        hints.macros = macros.mapValues { macro in
          Disassembly_Macro.with { proto in

            if let validArgumentValues = macro.validArgumentValues {
              proto.validArgumentValues = validArgumentValues.reduce(into: [:]) { accumulator, element in
                accumulator[UInt64(element.key)] = Disassembly_ValidArgumentValues.with { validArgumentValuesProto in
                  validArgumentValuesProto.ranges = element.value.rangeView.map { range in
                    Disassembly_Range.with { rangeProto in
                      rangeProto.inclusiveLower = UInt64(range.lowerBound)
                      rangeProto.exclusiveUpper = UInt64(range.upperBound)
                    }
                  }
                }
              }
            }

            proto.patterns = macro.patterns.map { patternLine in
              switch patternLine {
              case .any(let spec, let argument, let argumentText):
                return Disassembly_MacroPattern.with { patternProto in
                  if let opcode = spec.asData() {
                    patternProto.opcode = opcode
                  }
                  if let argumentText = argumentText {
                    patternProto.argumentText = argumentText
                  } else if let argument = argument {
                    patternProto.argument = argument
                  }
                }
              case .instruction(let instruction):
                return Disassembly_MacroPattern.with { patternProto in
                  if let opcode = instruction.spec.asData() {
                    patternProto.opcode = opcode
                  }
                  if let operands = instruction.operandData() {
                    patternProto.operands = operands
                  }
                }
              }
            }
          }
        }

        hints.datatypes = dataTypes.mapValues { datatype in
          Disassembly_Datatype.with { proto in
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

        hints.globals = globals.reduce(into: [:]) { accumulator, element in
          accumulator[UInt64(element.key)] = Disassembly_Global.with { proto in
            proto.name = element.value.name
            if let dataType = element.value.dataType {
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
  private var macros: [String: Macro] = [:]

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

  private struct Macro {
    let patterns: [MacroPattern]
    let validArgumentValues: [Int: IndexSet]?
  }

  private func createDatatype(named name: String, type: Datatype) {
    precondition(!name.isEmpty, "Data type has invalid name.")
    precondition(dataTypes[name] == nil, "Data type \(name) already exists.")
    dataTypes[name] = type
  }
}
