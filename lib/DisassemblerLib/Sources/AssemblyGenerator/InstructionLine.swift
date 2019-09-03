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
  var lines: [String] = []
  comment.enumerateLines { line, _ in
    lines.append(line)
  }
  return lines.map {
    "    ; \($0)"
  }.joined(separator: "\n")
}

public func line(_ code: String, comment: String) -> String {
  if code.count > codeWidth {
    return "\(codeColumn("")) ; \(comment)\n\(code)"
  } else {
    return "\(codeColumn(code)) ; \(comment)"
  }
}

public func line<T: FixedWidthInteger>(_ code: String, address: T, addressType: String?) -> String {
  return line("    \(code)", comment: addressAndType(address, type: addressType))
}

public func line(_ code: String) -> String {
  return "\(codeColumn("    \(code)"))"
}

public func line<T: FixedWidthInteger>(_ code: String, address: T, addressType: String?, comment: String) -> String {
  let aAndT = addressAndType(address, type: addressType)
  return line("    \(code)", comment: "\(aAndT) \(comment)")
}

public func line<T: FixedWidthInteger>(_ code: String, address: T, bank: UInt8, scope: String, bytes: Data) -> String {
  if !scope.isEmpty {
    return line("    \(code)", comment: "$\(address.hexString) (\(bank.hexString)): \(scope) \(bytes.map { "$\($0.hexString)" }.joined(separator: " "))")
  } else {
    return line("    \(code)", comment: "$\(address.hexString) (\(bank.hexString)): \(bytes.map { "$\($0.hexString)" }.joined(separator: " "))")
  }
}
