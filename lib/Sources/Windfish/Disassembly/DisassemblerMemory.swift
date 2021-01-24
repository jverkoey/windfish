import Foundation

final class DisassemblerMemory: AddressableMemory {
  init(data: Data) {
    self.data = data
  }
  let data: Data

  var selectedBank: Cartridge.Bank = 0

  func read(from address: LR35902.Address) -> UInt8 {
    let intAddress = Int(truncatingIfNeeded: address)
    guard intAddress < data.count else {
      return 0xff
    }

    // Read-only memory (ROM) bank 00
    if address <= 0x3FFF {
      return data[intAddress]
    }

    // Read-only memory (ROM) bank 01-7F
    if address >= 0x4000 && address <= 0x7FFF {
      let location = Cartridge.Location(address: address, bank: selectedBank)
      return data[location.index]
    }

    return 0xff
  }

  func write(_ byte: UInt8, to address: LR35902.Address) {
    // Ignore writes.
  }

  func sourceLocation(from address: LR35902.Address) -> Gameboy.SourceLocation {
    return .cartridge(Cartridge.Location(address: address, bank: selectedBank))
  }
}
