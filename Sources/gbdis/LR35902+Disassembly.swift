import Foundation

extension LR35902 {
  class Disassembly {
    private var instructionMap: [UInt32: Instruction] = [:]

    var code = IndexSet()
    func isCode(at pc: UInt16, in bank: UInt8) -> Bool {
      let address = LR35902.romAddress(for: pc, in: bank)
      return code.contains(Int(address))
    }

    func register(instruction: Instruction, at pc: UInt16, in bank: UInt8) {
      let address = LR35902.romAddress(for: pc, in: bank)

      instructionMap[address] = instruction

      code.insert(integersIn: Int(address)..<(Int(address) + Int(instruction.width)))
    }
    func instruction(at pc: UInt16, in bank: UInt8) -> Instruction? {
      let index = LR35902.romAddress(for: pc, in: bank)
      return instructionMap[index]
    }

    struct TransferOfControl: Hashable {
      enum Kind {
        case jr
        case jp
        case call
      }
      let sourceAddress: UInt16
      let kind: Kind
    }
    private var jumpMap: [UInt32: Set<TransferOfControl>] = [:]
    func registerTransferOfControl(to pc: UInt16, in bank: UInt8, from fromPc: UInt16, kind: TransferOfControl.Kind) {
      let index = LR35902.romAddress(for: pc, in: bank)
      jumpMap[index, default: Set()].insert(TransferOfControl(sourceAddress: fromPc, kind: kind))
    }
    func transfersOfControl(at pc: UInt16, in bank: UInt8) -> Set<TransferOfControl>? {
      let index = LR35902.romAddress(for: pc, in: bank)
      return jumpMap[index]
    }
  }
}
