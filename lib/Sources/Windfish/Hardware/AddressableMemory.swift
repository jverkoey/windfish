import Foundation

/** A region of addressable memory can be read from and written to. */
public protocol AddressableMemory {
  /** Read from the given address and return the resulting byte. */
  func read(from address: LR35902.Address) -> UInt8

  /** Write a byte to the given address. */
  mutating func write(_ byte: UInt8, to address: LR35902.Address)
}
