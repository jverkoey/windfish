import Foundation
import Windfish

final class FlagsFormatter: Formatter {
  override func string(for obj: Any?) -> String? {
    guard let flags = obj as? UInt8 else {
      return nil
    }
    let iflags = Int(truncatingIfNeeded: flags)
    return (((iflags & GB_CARRY_FLAG) != 0) ? "C" : "-")
      + (((iflags & GB_HALF_CARRY_FLAG) != 0) ? "H" : "-")
      + (((iflags & GB_SUBTRACT_FLAG) != 0) ? "N" : "-")
      + (((iflags & GB_ZERO_FLAG) != 0) ? "Z" : "-")
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
    guard let bank = Gameboy.Cartridge.Bank(numericalValue, radix: 16) else {
      return false
    }
    obj?.pointee = bank as AnyObject
    return true
  }
}

final class UInt8BinaryFormatter: Formatter {
  override func string(for obj: Any?) -> String? {
    guard let address = obj as? Gameboy.Cartridge.Bank else {
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
    guard let bank = Gameboy.Cartridge.Bank(numericalValue, radix: 2) else {
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
