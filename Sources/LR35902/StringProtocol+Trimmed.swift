import Foundation

extension StringProtocol {
  func trimmed() -> String {
    return trimmingCharacters(in: .whitespaces)
  }
}
