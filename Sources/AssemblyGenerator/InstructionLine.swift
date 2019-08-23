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
  if code.count + 4 > codeWidth {
    return "\(codeColumn("")) ; $\(address.hexString)\n    \(code)"
  }
  let column = codeColumn("    \(code)")
  return "\(column) ; $\(address.hexString)"
}

public func line(_ code: String) -> String {
  return "\(codeColumn("    \(code)"))"
}

public func line<T: FixedWidthInteger>(_ code: String, address: T, comment: String) -> String {
  return "\(codeColumn("    \(code)")) ; $\(address.hexString) \(comment)"
}

public func line<T: FixedWidthInteger>(_ code: String, address: T, bank: UInt8, scope: Set<String>, bytes: Data) -> String {
  if !scope.isEmpty {
    return "\(codeColumn("    \(code)")) ; $\(address.hexString) (\(bank.hexString)): \(scope.sorted().joined(separator: ", ")) \(bytes.map { "$\($0.hexString)" }.joined(separator: " "))"
  } else {
    return "\(codeColumn("    \(code)")) ; $\(address.hexString) (\(bank.hexString)): \(bytes.map { "$\($0.hexString)" }.joined(separator: " "))"
  }
}
