import Foundation

extension Disassembler {
  /** Registers a soft terminator at the given location. */
  func registerSoftTerminator(at location: Cartridge.Location) {
    softTerminators[location] = true
  }
}
