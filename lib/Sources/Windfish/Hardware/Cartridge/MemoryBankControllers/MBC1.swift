import Foundation

extension Gameboy.Cartridge {
  /** Implementation of the MBC1 memory bank controller. */
  struct MBC1: AddressableMemory {
    public var addressableRanges: [ClosedRange<LR35902.Address>] = [
      0x0000...0x7FFF
    ]

    init(data: Data) {
      self.data = data
    }

    public func read(from address: LR35902.Address) -> UInt8 {
      // Read-only memory (ROM) bank 00
      if address <= 0x3FFF {
        return data[Int(address)]
      }

      // Read-only memory (ROM) bank 01-7F
      if address >= 0x4000 && address <= 0x7FFF {
        guard let location = Gameboy.Cartridge.location(for: address, in: (selectedBank == 0) ? 1 : selectedBank) else {
          preconditionFailure("Invalid location for address 0x\(address.hexString) in bank 0x\(selectedBank.hexString)")
        }
        return data[Int(location)]
      }

      // Random-access memory (RAM) bank 00-03
      if address >= 0xA000 && address <= 0xBFFF {
        fatalError("RAM banks are not implemented yet.")
      }

      fatalError("Invalid read address provided to the cartridge: \(address).")
    }

    public mutating func write(_ byte: UInt8, to address: LR35902.Address) {
      // Read-only memory (ROM) bank number
      if address >= 0x2000 && address <= 0x3FFF {
        let mask: UInt8 = 0b0001_1111
        let maskedByte = byte & mask
        // 0 is always translated to bank 1.
        let adjustedByte = maskedByte != 0 ? maskedByte : 1
        selectedBank = (selectedBank & ~mask) | adjustedByte
      }

      // Random-access memory (RAM) bank number / upper bits of read-only memory (ROM) bank number
      if address >= 0x4000 && address <= 0x5FFF {
        fatalError("RAM Bank Number / Upper Bits of ROM Bank Number not implemented yet.")
      }

      // ROM/RAM mode select
      if address >= 0x6000 && address <= 0x7FFF {
        fatalError("ROM/RAM Mode Select not implemented yet.")
      }

      fatalError("Invalid write address provided to the cartridge: \(address).")
    }

    private var selectedBank: LR35902.Bank = 0
    private let data: Data
  }
}
