//
//  File.swift
//  
//
//  Created by Jeff Verkoeyen on 8/4/19.
//

import Foundation

extension FixedWidthInteger {
  var hexString: String {
    let zeroPrefix = String(repeating: "0", count: leadingZeroBitCount / 4)
    if self == 0 {
      return zeroPrefix
    } else {
      return zeroPrefix + String(self, radix: 16, uppercase: true)
    }
  }
}
