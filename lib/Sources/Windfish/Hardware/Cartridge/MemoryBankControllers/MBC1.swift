import Foundation

// References:
// - https://meatfighter.com/gameboy/TheNintendoGameboy.pdf
// - https://retrocomputing.stackexchange.com/questions/11732/how-does-the-gameboys-memory-bank-switching-work

extension Gameboy.Cartridge {
  /** Implementation of the MBC1 memory bank controller. */
  final class MBC1: MemoryBankController {
    deinit {
      data.deallocate()
    }

    init(data: Data) {
      self.data = UnsafeMutableRawBufferPointer.allocate(byteCount: data.count, alignment: 1)
      self.data.copyBytes(from: data)

      if data.count > 0x149,
         let ramSize = RAMSize(rawValue: data[0x149]){
        self.ramSize = ramSize
      } else {
        self.ramSize = .none
      }

      // TODO: Allow this to be saved to and loaded from disk.
      ram = UnsafeMutableRawBufferPointer.allocate(byteCount: self.ramSize.capacity, alignment: 1)
      ram.initializeMemory(as: UInt8.self, repeating: 0xff)
    }

    private(set) var selectedBank: Gameboy.Cartridge.Bank = 0
    private(set) var selectedRAMBank: Gameboy.Cartridge.Bank = 0
    private let data: UnsafeMutableRawBufferPointer

    /** Whether or not RAM is enabled. */
    var ramEnabled = false

    /** The cartridge's internal RAM. */
    var ram: UnsafeMutableRawBufferPointer

    private enum RAMSize: UInt8 {
      case none = 0
      case one2kb = 1
      case one8kb = 2
      case four32kb = 3
      case sixteen128kb = 4

      fileprivate var capacity: Int {
        switch self {
        case .none:         return 0
        case .one2kb:       return 2 * 1024
        case .one8kb:       return 8 * 1024
        case .four32kb:     return 32 * 1024
        case .sixteen128kb: return 128 * 1024
        }
      }
    }
    private let ramSize: RAMSize

    /** Possible ROM/RAM modes. */
    enum Mode {
      /** ROM Banking Mode (up to 8KByte RAM, 2MByte ROM). */
      case rom
      /** RAM Banking Mode (up to 32KByte RAM, 512KByte ROM). */
      case ram
    }
    var mode: Mode = .rom

    func read(from address: LR35902.Address) -> UInt8 {
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
        precondition(ramEnabled, "RAM is not enabled.")
        switch ramSize {
        case .none:
          return 0xff
        case .one2kb, .one8kb:
          return ram[Int(address) - 0xA000]
        case .four32kb, .sixteen128kb:
          preconditionFailure("Bankable RAM not implemented.")
        }
      }

      fatalError("Invalid read address provided to the cartridge: \(address).")
    }

    func write(_ byte: UInt8, to address: LR35902.Address) {
      // Read-only memory (ROM) bank number
      if address >= 0x2000 && address <= 0x3FFF {
        let mask: UInt8 = 0b0001_1111
        let maskedByte = byte & mask
        // 0 is always translated to bank 1.
        let adjustedByte = (maskedByte == 0) ? 1 : maskedByte
        selectedBank = (selectedBank & ~mask) | adjustedByte
        return
      }

      // Random-access memory (RAM) bank number / upper bits of read-only memory (ROM) bank number
      if address >= 0x4000 && address <= 0x5FFF {
        switch mode {
        case .rom:
          fatalError("Upper Bits of ROM Bank Number not implemented yet.")
        case .ram:
          let mask: UInt8 = 0b0000_0011
          let maskedByte = byte & mask
          selectedRAMBank = (selectedBank & ~mask) | maskedByte
          return
        }
      }

      // ROM/RAM mode select
      if address >= 0x6000 && address <= 0x7FFF {
        mode = ((byte & 0x01) == 0x01) ? .ram : .rom
        return
      }

      // ROM/RAM mode select
      if address >= 0x0000 && address <= 0x1FFF {
        ramEnabled = (byte & 0x0A) == 0x0A
        return
      }

      // Random-access memory (RAM) bank 00-03
      if address >= 0xA000 && address <= 0xBFFF {
        guard ramEnabled else {
          return
        }
        switch ramSize {
        case .none:  break  // Do nothing; there's no RAM to write to
        case .one2kb, .one8kb:
          ram[Int(address) - 0xA000] = byte
        case .four32kb, .sixteen128kb:
          fatalError("Bankable RAM not implemented: \(address.hexString).")
        }
        return
      }

      fatalError("Invalid write address provided to the cartridge: \(address.hexString).")
    }

    func sourceLocation(from address: LR35902.Address) -> Disassembler.SourceLocation {
      return .cartridge(Gameboy.Cartridge.location(for: address, in: (selectedBank == 0) ? 1 : selectedBank)!)
    }
  }
}
