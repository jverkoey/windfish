import Foundation

extension LR35902 {

  /// A class that owns and manages disassembly information for a given ROM.
  public class Disassembly {

    // MARK: - Querying disassembly information.

    // Indexes of bytes that are known to be code.
    public var code = IndexSet()

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
      transfers[index, default: Set()].insert(TransferOfControl(sourceAddress: fromPc, kind: kind))
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

    // MARK: - Bank changes

    public func bankChange(at pc: UInt16, in bank: UInt8) -> UInt8? {
      return bankChanges[LR35902.romAddress(for: pc, in: bank)]
    }

    func register(bankChange: UInt8, at pc: UInt16, in bank: UInt8) {
      bankChanges[LR35902.romAddress(for: pc, in: bank)] = bankChange
    }
    private var bankChanges: [UInt32: UInt8] = [:]
  }
}
