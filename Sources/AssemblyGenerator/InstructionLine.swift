import Foundation

import FixedWidthInteger

private let codeWidth = 48

private func codeColumn(_ code: String) -> String {
  return "\(code)".padding(toLength: codeWidth, withPad: " ", startingAt: 0)
}

public func line(comment: String) -> String {
  return "    ; \(comment)"
}

public func line(_ code: String, comment: String) -> String {
  return "\(codeColumn(code)) ; \(comment)"
}

public func line<T: FixedWidthInteger>(_ code: String, address: T) -> String {
  let column = codeColumn("    \(code)")
  if code.count > column.count {
    return "\(codeColumn("")) ; $\(address.hexString)\n    \(code)"
  }
  return "\(column) ; $\(address.hexString)"
}

public func line(_ code: String) -> String {
  return "\(codeColumn("    \(code)"))"
}

public func line<T: FixedWidthInteger>(_ code: String, address: T, comment: String) -> String {
  return "\(codeColumn("    \(code)")) ; $\(address.hexString) \(comment)"
}

public func line<T: FixedWidthInteger>(_ code: String, address: T, bytes: Data) -> String {
  return "\(codeColumn("    \(code)")) ; $\(address.hexString): \(bytes.map { "$\($0.hexString)" }.joined(separator: " "))"
}
