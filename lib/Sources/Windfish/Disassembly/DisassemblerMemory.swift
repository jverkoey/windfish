import Foundation

final class DisassemblerMemory: AddressableMemory {
  init(data: Data) {
    self.data = data
  }
  let data: Data

  var selectedBank: Cartridge.Bank = 0

  func read(from address: LR35902.Address) -> UInt8 {
    // Read-only memory (ROM) bank 00
    if address <= 0x3FFF {
      return data[Int(address)]
    }

    // Read-only memory (ROM) bank 01-7F
    if address >= 0x4000 && address <= 0x7FFF {
      let location = Cartridge.Location(address: address, bank: selectedBank)
      return data[location.index]
    }

    fatalError()
  }

  func write(_ byte: UInt8, to address: LR35902.Address) {
    fatalError()
  }

  func sourceLocation(from address: LR35902.Address) -> Gameboy.SourceLocation {
    return .cartridge(Cartridge.Location(address: address, bank: selectedBank))
  }
}
