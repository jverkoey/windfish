import Foundation

import FixedWidthInteger

private let codeWidth = 48

private func codeColumn(_ code: String) -> String {
  return "\(code)".padding(toLength: codeWidth, withPad: " ", startingAt: 0)
}

public func line(_ code: String, comment: String) -> String {
  return "\(codeColumn(code)) ; \(comment)"
}

public func line<T: FixedWidthInteger>(_ code: String, address: T, comment: String) -> String {
  return "\(codeColumn("    \(code)")) ; $\(address.hexString) \(comment)"
}

public func line<T: FixedWidthInteger>(_ code: String, address: T, bytes: Data) -> String {
  return "\(codeColumn("    \(code)")) ; $\(address.hexString): \(bytes.map { "$\($0)" }.joined(separator: " "))"
}
