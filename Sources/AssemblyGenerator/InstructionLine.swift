import Foundation

import FixedWidthInteger

private let codeWidth = 48

private func addressAndType<T: FixedWidthInteger>(_ address: T, type: String?) -> String {
  if let type = type {
    return "$\(address.hexString) (\(type))"
  } else {
    return "$\(address.hexString)"
  }
}

private func codeColumn(_ code: String) -> String {
  return "\(code)".padding(toLength: codeWidth, withPad: " ", startingAt: 0)
}

public func line(comment: String) -> String {
  return "    ; \(comment)"
}

public func line(_ code: String, comment: String) -> String {
  return "\(codeColumn(code)) ; \(comment)"
}

public func line<T: FixedWidthInteger>(_ code: String, address: T, addressType: String?) -> String {
  let aAndT = addressAndType(address, type: addressType)
  if code.count + 4 > codeWidth {
    return "\(codeColumn("")) ; \(aAndT)\n    \(code)"
  }
  let column = codeColumn("    \(code)")
  return "\(column) ; \(aAndT)"
}

public func line(_ code: String) -> String {
  return "\(codeColumn("    \(code)"))"
}

public func line<T: FixedWidthInteger>(_ code: String, address: T, addressType: String?, comment: String) -> String {
  let aAndT = addressAndType(address, type: addressType)
  return "\(codeColumn("    \(code)")) ; \(aAndT) \(comment)"
}

public func line<T: FixedWidthInteger>(_ code: String, address: T, bank: UInt8, scope: Set<String>, bytes: Data) -> String {
  if !scope.isEmpty {
    return "\(codeColumn("    \(code)")) ; $\(address.hexString) (\(bank.hexString)): \(scope.sorted().joined(separator: ", ")) \(bytes.map { "$\($0.hexString)" }.joined(separator: " "))"
  } else {
    return "\(codeColumn("    \(code)")) ; $\(address.hexString) (\(bank.hexString)): \(bytes.map { "$\($0.hexString)" }.joined(separator: " "))"
  }
}
