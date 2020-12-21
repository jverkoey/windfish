//
//  LR35902AddressFormatter.swiftui
//
//  Created by Jeff Verkoeyen on 12/4/20.
//

import Foundation
import Windfish

final class UInt8HexFormatter: Formatter {
  override func string(for obj: Any?) -> String? {
    guard let address = obj as? LR35902.Bank else {
      return nil
    }
    return "0x\(address.hexString)"
  }

  override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                               for string: String,
                               errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
    let numericalValue: String
    if string.hasPrefix("0x") {
      numericalValue = String(string.dropFirst(2))
    } else {
      numericalValue = string
    }
    guard let bank = LR35902.Bank(numericalValue, radix: 16) else {
      return false
    }
    obj?.pointee = bank as AnyObject
    return true
  }
}

final class UInt8BinaryFormatter: Formatter {
  override func string(for obj: Any?) -> String? {
    guard let address = obj as? LR35902.Bank else {
      return nil
    }
    return "0b\(address.binaryString)"
  }

  override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                               for string: String,
                               errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
    let numericalValue: String
    if string.hasPrefix("0b") {
      numericalValue = String(string.dropFirst(2))
    } else {
      numericalValue = string
    }
    guard let bank = LR35902.Bank(numericalValue, radix: 2) else {
      return false
    }
    obj?.pointee = bank as AnyObject
    return true
  }
}

final class LR35902AddressFormatter: Formatter {
  override func string(for obj: Any?) -> String? {
    guard let address = obj as? LR35902.Address else {
      return nil
    }
    return "0x\(address.hexString)"
  }

  override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                               for string: String,
                               errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
    let numericalValue: String
    if string.hasPrefix("0x") {
      numericalValue = String(string.dropFirst(2))
    } else {
      numericalValue = string
    }
    guard let address = LR35902.Address(numericalValue, radix: 16) else {
      return false
    }
    obj?.pointee = address as AnyObject
    return true
  }
}
