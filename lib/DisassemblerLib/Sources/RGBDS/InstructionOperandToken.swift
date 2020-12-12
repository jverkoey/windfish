import Foundation

import FoundationExtensions

/** An operand token represents one operand of an instruction in RGBDS assembly. */
public enum InstructionOperandToken: Equatable {
  /** A generic numeric token. Examples: 123, 0xff, 0b10101010. */
  case numeric

  /** An generic address token. Examples: [$abcd], [$dd]. */
  case address

  /** An generic FF## address token. Examples: [$ff12]. */
  case ffaddress

  /** A generic stack pointer offset token. Examples: sp+$fa. */
  case stackPointerOffset

  /**
   A specific token.

   Examples: [bc].

   Primarily used when the token is specific but can't be correctly inferred from the operand's type.
   */
  case specific(String)

  /** Creates a token from the given string. */
  public init(string: String) {
    if isNumber(string) {
      self = .numeric
      return
    }

    if string.hasPrefix("[") && string.hasSuffix("]") {
      let withinBrackets = String(string.dropFirst().dropLast())
      if withinBrackets.lowercased().hasPrefix("$ff") && withinBrackets.count == 5 {
        self = .ffaddress
        return
      }
      if isNumber(withinBrackets) {
        self = .address
        return
      }
    }

    if string.lowercased().hasPrefix("sp+") {
      self = .stackPointerOffset
      return
    }

    self = .specific(string)
  }

  /** Returns a representation of this token as a string. */
  public func asString() -> String {
    switch self {
    case .numeric:
      return "#"
    case .address:
      return "[#]"
    case .ffaddress:
      return "[ff#]"
    case .stackPointerOffset:
      return "sp+#"
    case let .specific(string):
      return string
    }
  }
}

/** An abstract representation of an instruction's operand as an RGBDS token. */
public protocol InstructionOperandTokenizable {
  /** The operand's representation as an RGBDS token. */
  var token: InstructionOperandToken { get }
}

private func isNumber(_ string: String) -> Bool {
  // https://rgbds.gbdev.io/docs/v0.4.2/rgbasm.5#Numeric_Formats
  return
    string.hasPrefix("$") // Hex
    || string.hasPrefix("&") // Octal
    || string.hasPrefix("%") // Binary
    || string.hasPrefix("#") // Placeholder
    || string.hasPrefix("`") // Gameboy graphics
    || Int(string) != nil
    || (string.contains(".") && Float(string) != nil)
}

public struct StringError: Swift.Error, Equatable {
  public init(error: String) {
    self.error = error
  }

  public let error: String
}

public func cast<T: UnsignedInteger, negT: SignedInteger>(string: String, negativeType: negT.Type) throws -> T where T: FixedWidthInteger, negT: FixedWidthInteger, T: BitPatternInitializable, T.CompanionType == negT {
  var value = string
  let isNegative = value.starts(with: "-")
  if isNegative {
    value = String(value.dropFirst(1))
  }

  var numericPart: String
  var radix: Int
  if value.starts(with: "$") {
    numericPart = String(value.dropFirst())
    radix = 16
  } else if value.starts(with: "0x") {
    numericPart = String(value.dropFirst(2))
    radix = 16
  } else if value.starts(with: "%") {
    numericPart = String(value.dropFirst())
    radix = 2
  } else {
    numericPart = value
    radix = 10
  }

  if isNegative {
    guard let negativeValue = negT(numericPart, radix: radix) else {
      throw StringError(error: "Unable to represent \(value) as a UInt16")
    }
    return T(bitPattern: -negativeValue)
  } else if let numericValue = T(numericPart, radix: radix) {
    return numericValue
  }

  throw StringError(error: "Unable to represent \(value) as a UInt16")
}
