import Foundation

class LR35902 {
  var pc: UInt16 = 0
  var bank: UInt8 = 0

  let rom: Data
  init(rom: Data) {
    self.rom = rom
    self.disassembly = Disassembly(size: UInt32(rom.count))
  }

  private let disassembly: Disassembly

  func disassemble(startingFrom pcInitial: UInt16, inBank bankInitial: UInt8) {
    self.bank = bankInitial
    self.pc = pcInitial

    while true {
      let byte = rom[Int(pc)]
      if let instruction = LR35902.opcodeDescription[byte] {
        disassembly.register(instruction: instruction, at: pc, in: bank)

        let nextPc = pc + instruction.byteWidth

        switch instruction {
        case .jr(.immediate8, _):
          let relativeJumpAmount = UInt16(rom[Int(pc + 1)])
          let jumpTo = nextPc + relativeJumpAmount
          disassembly.register(jumpAddress: jumpTo, in: bank, kind: .relative)

        case .jp(.immediate16, _):
          let jumpLow = UInt16(rom[Int(pc + 1)])
          let jumpHigh = UInt16(rom[Int(pc + 2)]) << 8
          let jumpTo = jumpHigh | jumpLow
          disassembly.register(jumpAddress: jumpTo, in: bank, kind: .absolute)

        default:
          break
        }

        self.pc = nextPc
      }
    }
  }

  static let bankSize: UInt32 = 0x4000
}
