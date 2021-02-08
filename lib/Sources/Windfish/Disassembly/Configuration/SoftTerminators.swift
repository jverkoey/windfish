import Foundation

import Tracing

extension Disassembler.MutableConfiguration {
  func shouldTerminateLinearSweep(at location: Cartridge.Location) -> Bool {
    return softTerminators[location] != nil
  }

  /** Registers a soft terminator at the given location. */
  func registerSoftTerminator(at location: Cartridge.Location) {
    softTerminators[location] = true
  }
}
