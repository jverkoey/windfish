import Foundation

extension StringProtocol {
  /** Returns a new string made by removing whitespace characters from both ends of the receiver. */
  public func trimmed() -> String {
    return trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
