import Foundation
import CPU

/** A barebones implementation of a hypothetical CPU. */
struct SimpleCPU {
  /** A concrete representation of a single instruction for this CPU. */
  struct Instruction: CPU.Instruction {
    let spec: Instruction.Spec

    enum ImmediateValue: CPU.InstructionImmediate {
      public init?(data: Data) {
        switch data.count {
        case 1:
          self = .imm8(data[0])
        case 2:
          let low = UInt16(data[0])
          let high = UInt16(data[1]) << 8
          let immediate16 = high | low
          self = .imm16(immediate16)
        default:
          return nil
        }
      }

      public func asData() -> Data {
        switch self {
        case let .imm8(immediate):
          return Data([immediate])
        case var .imm16(immediate):
          return withUnsafeBytes(of: &immediate) { immediateBytes in
            return Data(immediateBytes)
          }
        }
      }

      case imm8(UInt8)
      case imm16(UInt16)
    }
    let immediate: ImmediateValue?

    /** The shape of an instruction for this CPU. */
    indirect enum Spec: CPU.InstructionSpec {
      typealias WidthType = UInt16

      case nop
      case cp(Numeric)
      case ld(Numeric, Numeric)
      case call(Condition? = nil, Numeric)
      case prefix(PrefixTable)

      case sub(Spec)

      enum Numeric: Hashable {
        case imm8
        case imm16
        case a
        case arg(Int)
      }

      enum Condition: Hashable {
        case nz
        case z
      }

      enum PrefixTable: Hashable {
        case sub
      }
    }
  }

  struct InstructionSet: CPU.InstructionSet {
    typealias InstructionType = Instruction

    static let table: [Instruction.Spec] = [
      /* 0x00 */ .nop,
      /* 0x01 */ .ld(.a, .imm8),
      /* 0x02 */ .ld(.a, .imm16),
      /* 0x03 */ .call(.nz, .imm16),
      /* 0x04 */ .call(nil, .imm16),
      /* 0x05 */ .prefix(.sub),
    ]
    static let subTable: [Instruction.Spec] = [
      /* 0x00 */ .sub(.cp(.imm8)),
    ]
    static var prefixTables: [Instruction.Spec: [Instruction.Spec]] = [
      .prefix(.sub): subTable
    ]

    static var widths: [Instruction.Spec : InstructionWidth<UInt16>] = {
      return computeAllWidths()
    }()

    static var opcodeBytes: [Instruction.Spec : [UInt8]] = {
      return computeAllOpcodeBytes()
    }()

    static var opcodeStrings: [SpecType : String] = {
      return computeAllOpcodeStrings()
    }()
  }
}

extension SimpleCPU.Instruction.Spec.Numeric: InstructionOperandWithBinaryFootprint {
  var width: Int {
    switch self {
    case .imm8:
      return 1
    case .imm16:
      return 2
    default:
      return 0
    }
  }
}
