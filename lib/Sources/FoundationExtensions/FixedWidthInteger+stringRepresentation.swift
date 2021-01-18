import Foundation

extension FixedWidthInteger {
  /** Returns an uppercase hexadecimal string representation of this integer. */
  public var hexString: String {
    // Divide leadingZeroBitCount by 4 because there are four bits per hexadecimal character.
    let zeroPrefix = String(repeating: "0", count: leadingZeroBitCount / 4)
    if self != 0 {
      return zeroPrefix + String(self, radix: 16, uppercase: true)
    }
    // Only return the prefix when zero, otherwise the String representation of self will add an extra zero to the
    // prefix.
    return zeroPrefix
  }

  /** Returns a binary string representation of this integer. */
  public var binaryString: String {
    let zeroPrefix = String(repeating: "0", count: leadingZeroBitCount)
    if self != 0 {
      return zeroPrefix + String(self, radix: 2, uppercase: true)
    }
    // Only return the prefix when zero, otherwise the String representation of self will add an extra zero to the
    // prefix.
    return zeroPrefix
  }
}
