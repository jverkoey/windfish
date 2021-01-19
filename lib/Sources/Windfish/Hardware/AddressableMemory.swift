import Foundation

/** A region of addressable memory can be read from and written to. */
protocol AddressableMemory: class {
  /** Read from the given address and return the resulting byte. */
  func read(from address: LR35902.Address) -> UInt8

  /** Write a byte to the given address. */
  func write(_ byte: UInt8, to address: LR35902.Address)

  /** Returns a source code location for the given address based on the current memory configuration. */
  func sourceLocation(from address: LR35902.Address) -> Gameboy.SourceLocation
}
