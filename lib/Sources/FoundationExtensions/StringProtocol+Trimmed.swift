import Foundation

extension StringProtocol {
  public func trimmed() -> String {
    return trimmingCharacters(in: .whitespaces)
  }
}
