import Foundation

extension InstructionSet {
  /** Generates a binary data representation of the given specification. */
  public static func data(for spec: SpecType) -> Data? {
    guard let bytes = opcodeBytes[spec] else {
      return nil
    }
    return Data(bytes)
  }
}
