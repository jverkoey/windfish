import Foundation

import CPU
import LR35902

/** A region of addressable memory can be read from and written to. */
protocol TraceableMemory: class {
  /** Read from the given address and return the resulting byte, if it's known. */
  func read(from address: LR35902.Address) -> UInt8?

  /** Write a byte to the given address. Writing nil will clear any known value at the given address. */
  func write(_ byte: UInt8?, to address: LR35902.Address)

  /** Returns a source code location for the given address based on the current memory configuration. */
  func sourceLocation(from address: LR35902.Address) -> Gameboy.SourceLocation

  /** Trace information for a given register. */
  var registerTraces: [LR35902.Instruction.Numeric: [LR35902.RegisterTrace]] { get set }
}
