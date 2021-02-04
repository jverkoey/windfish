import Foundation

extension Disassembler.MutableConfiguration {
  func label(at location: Cartridge.Location) -> String? {
    return labelNames[location]
  }

  /** Registers a label name at a specific location. */
  public func registerLabel(at location: Cartridge.Location, named name: String) {
    // TODO: Make this throw an exception that can be presented to the user.
    precondition(!name.contains("."), "Labels cannot contain dots.")
    labelNames[location] = name
  }
}
