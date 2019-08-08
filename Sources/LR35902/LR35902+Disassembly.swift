import Foundation

extension LR35902 {

  /// A class that owns and manages disassembly information for a given ROM.
  public class Disassembly {

    // MARK: - Querying disassembly information.

    // Indexes of bytes that are known to be code.
    public var code = IndexSet()

    public struct TransferOfControl: Hashable {
      public enum Kind {
        case jr, jp, call
      }
      public let sourceAddress: UInt16
      public let kind: Kind
    }
    public func instruction(at pc: UInt16, in bank: UInt8) -> Instruction? {
      return instructionMap[LR35902.romAddress(for: pc, in: bank)]
    }
    public func transfersOfControl(at pc: UInt16, in bank: UInt8) -> Set<TransferOfControl>? {
      return transfers[LR35902.romAddress(for: pc, in: bank)]
    }

    // MARK: - Registering new information about the ROM.

    func register(instruction: Instruction, at pc: UInt16, in bank: UInt8) {
      let address = LR35902.romAddress(for: pc, in: bank)
      instructionMap[address] = instruction

      code.insert(integersIn: Int(address)..<(Int(address) + Int(instruction.width)))
    }
    private var instructionMap: [UInt32: Instruction] = [:]

    func registerTransferOfControl(to pc: UInt16, in bank: UInt8, from fromPc: UInt16, kind: TransferOfControl.Kind) {
      let index = LR35902.romAddress(for: pc, in: bank)
      transfers[index, default: Set()].insert(TransferOfControl(sourceAddress: fromPc, kind: kind))
    }
    private var transfers: [UInt32: Set<TransferOfControl>] = [:]
  }
}
