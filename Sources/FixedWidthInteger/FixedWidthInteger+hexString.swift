import Foundation

extension FixedWidthInteger {
  public var hexString: String {
    let zeroPrefix = String(repeating: "0", count: leadingZeroBitCount / 4)
    if self == 0 {
      return zeroPrefix
    } else {
      return zeroPrefix + String(self, radix: 16, uppercase: true)
    }
  }

  public var binaryString: String {
    let zeroPrefix = String(repeating: "0", count: leadingZeroBitCount)
    if self == 0 {
      return zeroPrefix
    } else {
      return zeroPrefix + String(self, radix: 2, uppercase: true)
    }
  }
}
