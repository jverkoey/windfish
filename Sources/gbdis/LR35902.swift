import Foundation

class LR35902 {
  var pc: UInt16 = 0

  let rom: Data
  init(rom: Data) {
    self.rom = rom
  }

  static let bankSize: UInt64 = 0x4000
}
