import Foundation

import FixedWidthInteger

private let codeWidth = 48

public func line<T: FixedWidthInteger>
  (_ instruction: String,
   address: T,
   bytes: Data? = nil,
   comment: String? = nil) -> String {
  let code = "    \(instruction)".padding(toLength: codeWidth, withPad: " ", startingAt: 0)

  var parts = ["\(code) ; $\(address)"]

  if let bytes = bytes {
    parts.append(": ")
    parts.append(bytes.map { "$\($0)" }.joined(separator: " "))
  }

  if let comment = comment {
    parts.append(" ")
    parts.append(comment)
  }

  return parts.joined()
}
