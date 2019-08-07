import Foundation

extension LR35902 {
  static func romAddress(for pc: UInt16, in bank: UInt8) -> UInt32 {
    if pc < 0x4000 {
      return UInt32(pc)
    } else {
      return UInt32(bank) * LR35902.bankSize + UInt32(pc - 0x4000)
    }
  }

  class Disassembly {
    private var instructionMap: [UInt32: Instruction] = [:]
    private var jumpMap: [UInt32: JumpKind] = [:]

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

    enum JumpKind {
      case relative
      case absolute
    }
    // TODO: Register the source location and the type of call. This will need to be an accumulating object.
    func register(jumpAddress pc: UInt16, in bank: UInt8, kind: JumpKind) {
      let index = LR35902.romAddress(for: pc, in: bank)
      jumpMap[index] = kind
    }
    func jump(at pc: UInt16, in bank: UInt8) -> JumpKind? {
      let index = LR35902.romAddress(for: pc, in: bank)
      return jumpMap[index]
    }
  }
}
