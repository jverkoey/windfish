import Foundation

class LR35902 {
  var pc: UInt16 = 0
  var bank: UInt8 = 0

  let rom: Data
  init(rom: Data) {
    self.rom = rom
  }

  private let disassembly = Disassembly()

  struct BankedAddress: Hashable {
    let bank: UInt8
    let address: UInt16
  }

  func disassemble(startingFrom pcInitial: UInt16, inBank bankInitial: UInt8) {
    var jumpAddresses = Set<BankedAddress>()
    jumpAddresses.insert(BankedAddress(bank: bankInitial, address: pcInitial))

    var visitedAddresses = IndexSet()

    while !jumpAddresses.isEmpty {
      let address = jumpAddresses.removeFirst()
      self.bank = address.bank
      self.pc = address.address

      linear_sweep: while true {
        let byte = rom[Int(pc)]
        guard var instruction = LR35902.opcodeDescription[byte] else {
          pc += 1
          continue
        }
        if case .cb = instruction {
          pc += 1
          let byte = rom[Int(pc)]
          guard let cbInstruction = LR35902.cbOpcodeDescription[byte] else {
            pc += 1
            continue
          }
          instruction = cbInstruction
        }
        if case .invalid = instruction {
          pc += 1
          continue
        }
        print("\(pc.hexString): \(instruction.name) \(instruction.operands)")
        disassembly.register(instruction: instruction, at: pc, in: bank)

        let nextPc = pc + instruction.byteWidth

        let lowerBound = Int(pc) + Int(bank) * Int(LR35902.bankSize)
        visitedAddresses.insert(integersIn: lowerBound..<(lowerBound + Int(instruction.byteWidth)))

        switch instruction {
        case .jr(.immediate8, let condition):
          let relativeJumpAmount = UInt16(rom[Int(pc + 1)])
          let jumpTo = nextPc + relativeJumpAmount
          if !visitedAddresses.contains(Int(jumpTo)) {
            jumpAddresses.insert(BankedAddress(bank: bank, address: jumpTo))
          }
          disassembly.register(jumpAddress: jumpTo, in: bank, kind: .relative)

          if condition == nil {
            break linear_sweep
          }

        case .jp(.immediate16, let condition):
          let jumpLow = UInt16(rom[Int(pc + 1)])
          let jumpHigh = UInt16(rom[Int(pc + 2)]) << 8
          let jumpTo = jumpHigh | jumpLow
          if !visitedAddresses.contains(Int(jumpTo)) {
            jumpAddresses.insert(BankedAddress(bank: bank, address: jumpTo))
          }
          disassembly.register(jumpAddress: jumpTo, in: bank, kind: .absolute)

          if condition == nil {
            break linear_sweep
          }

        case .jp(_, nil):
          break linear_sweep

        default:
          break
        }

        self.pc = nextPc
      }
    }
  }

  static let bankSize: UInt32 = 0x4000
}
