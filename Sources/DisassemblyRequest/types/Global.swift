import Foundation

struct Global: ExpressibleByStringLiteral {
  let name: String
  let dataType: String?

  public init(stringLiteral: String) {
    let nameParts = stringLiteral.split(separator: " ")
    if nameParts.count > 1 {
      self.name = String(nameParts[1])
      self.dataType = String(nameParts[0])
    } else {
      self.name = stringLiteral
      self.dataType = nil
    }
  }
}
