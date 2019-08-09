import Foundation

extension LR35902 {

  /// A class that owns and manages disassembly information for a given ROM.
  public class Disassembly {

    // MARK: - Querying disassembly information.

    // MARK: - Labels

    public func label(at pc: UInt16, in bank: UInt8) -> String? {
      return labels[LR35902.romAddress(for: pc, in: bank)]
    }

    public func setLabel(at pc: UInt16, in bank: UInt8, named name: String) {
      labels[LR35902.romAddress(for: pc, in: bank)] = name
    }
    private var labels: [UInt32: String] = [:]

    // MARK: - Transfers of control

    public struct TransferOfControl: Hashable {
      public enum Kind {
        case jr, jp, call
      }
      public let sourceAddress: UInt16
      public let kind: Kind
    }
    public func transfersOfControl(at pc: UInt16, in bank: UInt8) -> Set<TransferOfControl>? {
      return transfers[LR35902.romAddress(for: pc, in: bank)]
    }

    func registerTransferOfControl(to pc: UInt16, in bank: UInt8, from fromPc: UInt16, kind: TransferOfControl.Kind) {
      let index = LR35902.romAddress(for: pc, in: bank)
      transfers[index, default: Set()]
        .insert(TransferOfControl(sourceAddress: fromPc, kind: kind))
      if labels[index] == nil
        // Don't create a label in the middle of an instruction.
        && (!code.contains(Int(index)) || instruction(at: pc, in: bank) != nil) {
        labels[index] = RGBDSAssembly.defaultLabel(at: pc, in: bank)
      }
    }
    private var transfers: [UInt32: Set<TransferOfControl>] = [:]

    // MARK: - Instructions

    public func instruction(at pc: UInt16, in bank: UInt8) -> Instruction? {
      return instructionMap[LR35902.romAddress(for: pc, in: bank)]
    }

    func register(instruction: Instruction, at pc: UInt16, in bank: UInt8) {
      let address = LR35902.romAddress(for: pc, in: bank)
      instructionMap[address] = instruction

      code.insert(integersIn: Int(address)..<(Int(address) + Int(instruction.width)))
    }
    private var instructionMap: [UInt32: Instruction] = [:]

    // MARK: - Data segments

    public func setData(at address: UInt16, in bank: UInt8) {
      data.insert(Int(LR35902.romAddress(for: address, in: bank)))
    }
    public func setData(at range: Range<UInt16>, in bank: UInt8) {
      let lowerBound = LR35902.romAddress(for: range.lowerBound, in: bank)
      let upperBound = LR35902.romAddress(for: range.upperBound, in: bank)
      data.insert(integersIn: Int(lowerBound)..<Int(upperBound))
    }

    // MARK: - Text segments

    public func setText(at range: Range<UInt16>, in bank: UInt8) {
      let lowerBound = LR35902.romAddress(for: range.lowerBound, in: bank)
      let upperBound = LR35902.romAddress(for: range.upperBound, in: bank)
      text.insert(integersIn: Int(lowerBound)..<Int(upperBound))
    }

    // MARK: - Comments

    public func preComment(at address: UInt16, in bank: UInt8) -> String? {
      return preComments[LR35902.romAddress(for: address, in: bank)]
    }
    public func setPreComment(at address: UInt16, in bank: UInt8, text: String) {
      preComments[LR35902.romAddress(for: address, in: bank)] = text
    }
    private var preComments: [UInt32: String] = [:]

    // MARK: - Bank changes

    public func bankChange(at pc: UInt16, in bank: UInt8) -> UInt8? {
      return bankChanges[LR35902.romAddress(for: pc, in: bank)]
    }

    func register(bankChange: UInt8, at pc: UInt16, in bank: UInt8) {
      bankChanges[LR35902.romAddress(for: pc, in: bank)] = bankChange
    }
    private var bankChanges: [UInt32: UInt8] = [:]

    // MARK: - Regions

    public enum ByteType {
      case unknown
      case code
      case data
      case text
    }
    public func type(of address: UInt16, in bank: UInt8) -> ByteType {
      let index = Int(LR35902.romAddress(for: address, in: bank))
      if code.contains(index) {
        return .code
      } else if data.contains(index) {
        return .data
      } else if text.contains(index) {
        return .text
      } else {
        return .unknown
      }
    }

    private var code = IndexSet()
    private var data = IndexSet()
    private var text = IndexSet()
  }
}
