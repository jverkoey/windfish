import Foundation

import LR35902
import Windfish

final class FlagsFormatter: Formatter {
  override func string(for obj: Any?) -> String? {
    guard let flags = obj as? UInt8 else {
      return nil
    }
    let iflags = Int(truncatingIfNeeded: flags)
    return (((iflags & GBFlag.carry.rawValue) != 0) ? "C" : "-")
      + (((iflags & GBFlag.halfCarry.rawValue) != 0) ? "H" : "-")
      + (((iflags & GBFlag.subtract.rawValue) != 0) ? "N" : "-")
      + (((iflags & GBFlag.zero.rawValue) != 0) ? "Z" : "-")
  }
}

final class UInt8HexFormatter: Formatter {
  override func string(for obj: Any?) -> String? {
    guard let address = obj as? UInt8 else {
      return nil
    }
    return "$" + address.hexString
  }

  override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                               for string: String,
                               errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
    let numericalValue: String
    if string.hasPrefix("$") {
      numericalValue = String(string.dropFirst(1))
    } else {
      numericalValue = string
    }
    guard let bank = Cartridge.Bank(numericalValue, radix: 16) else {
      return false
    }
    obj?.pointee = bank as AnyObject
    return true
  }
}

final class UInt8BinaryFormatter: Formatter {
  override func string(for obj: Any?) -> String? {
    guard let address = obj as? Cartridge.Bank else {
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
    guard let bank = Cartridge.Bank(numericalValue, radix: 2) else {
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
    return "$\(address.hexString)"
  }

  override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                               for string: String,
                               errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
    let numericalValue: String
    if string.hasPrefix("$") {
      numericalValue = String(string.dropFirst(1))
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
