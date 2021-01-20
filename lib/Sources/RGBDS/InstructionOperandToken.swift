import Foundation

import FoundationExtensions

/**
 An operand token is an abstract representation of a single operand within an RGBDS assembly instruction.

 This enables a statement to be represented as a pattern to which other instructions can be matched. This is primarily
 used by the Windfish macro system.
 */
public enum InstructionOperandToken: Equatable {
  /** A generic numeric token. Examples: 123, 0xff, 0b10101010. */
  case numeric

  /** An generic address token. Examples: [$abcd], [$dd]. */
  case address

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
    let lowercasedString: String = string.lowercased()
    if lowercasedString.hasPrefix("sp+") {
      self = .stackPointerOffset
      return
    }

    if lowercasedString == "[$ff00+c]" {
      self = .specific(string)
      return
    }

    if (string.hasPrefix("@+") || string.hasPrefix("@-")) && isNumber(String(string.dropFirst(2))) {
      self = .numeric
      return
    }

    if isNumber(string) || (string.hasPrefix("bank(") && string.hasSuffix(")")) {
      self = .numeric
      return
    }

    if string.hasPrefix("[") && string.hasSuffix("]") {
      let withinBrackets: String = String(string.dropFirst().dropLast())
      if isNumber(withinBrackets) {
        self = .address
        return
      }
    }

    self = .specific(string)
  }

  /** Returns a representation of this token as a string. */
  public func asString() -> String {
    switch self {
    case .numeric:              return "#"
    case .address:              return "[#]"
    case .stackPointerOffset:   return "sp+#"
    case .specific(let string): return string
    }
  }
}

/** An abstract representation of an instruction's operand as an RGBDS token. */
public protocol InstructionOperandTokenizable {
  /** The operand's representation as an RGBDS token. */
  var token: InstructionOperandToken { get }
}

/**
 Returns true if the given string is a numerical representation in RGBDS.

 Reference: https://rgbds.gbdev.io/docs/v0.4.2/rgbasm.5#Numeric_Formats
 */
private func isNumber(_ string: String) -> Bool {
  return
    string.hasPrefix(NumericPrefix.hexadecimal)
    || string.hasPrefix(NumericPrefix.octal)
    || string.hasPrefix(NumericPrefix.binary)
    || string.hasPrefix(NumericPrefix.placeholder)
    || string.hasPrefix(NumericPrefix.gameboyGraphics)
    || (string.hasPrefix("-") && isNumber(String(string.dropFirst())))
    || Int(string) != nil
    || (string.contains(".") && Float(string) != nil)
}

// MARK: - RGBDS string -> number conversions

/** Returns a UInt16 representation of the string, assuming the string is represented using RGBDS address notation. */
public func integer(fromAddress string: String) -> UInt16? {
  precondition(string.hasPrefix("[") && string.hasSuffix("]"))
  return integer(from: String(string.dropFirst().dropLast().trimmed()))
}

/**
 Returns a UInt8 representation of the string, assuming the string is represented using RGBDS stack pointer notation.
 */
public func integer(fromStackPointer string: String) -> UInt8? {
  precondition(string.hasPrefix("sp+"))
  return integer(from: String(string.dropFirst(3).trimmed()))
}

/**
 Returns a UInt16 representation of the string, assuming the string is represented using RGBDS numeric notation.

 Negative values are bit-casted to UInt16 from an Int16 representation first.
 */
public func integer(from string: String) -> UInt16? {
  var value: String = string
  let isNegative: Bool = value.starts(with: "-")
  if isNegative {
    value = String(value.dropFirst(1))
  }

  var numericPart: String
  var radix: Int
  if value.starts(with: NumericPrefix.hexadecimal) {
    numericPart = String(value.dropFirst())
    radix = 16
  } else if value.starts(with: NumericPrefix.octal) {
    numericPart = String(value.dropFirst())
    radix = 8
  } else if value.starts(with: NumericPrefix.binary) {
    numericPart = String(value.dropFirst())
    radix = 2
  } else {
    numericPart = value
    radix = 10
  }

  if isNegative {
    guard let negativeValue: Int16 = Int16(numericPart, radix: radix) else {
      return nil
    }
    return UInt16(bitPattern: -negativeValue)
  }

  guard let numericValue = UInt16(numericPart, radix: radix) else {
    return nil
  }

  return numericValue
}

/**
 Returns a UInt8 representation of the string, assuming the string is represented using RGBDS numeric notation.

 Negative values are bit-casted to UInt8 from an Int8 representation first.
 */
public func integer(from string: String) -> UInt8? {
  var value: String = string
  let isNegative: Bool = value.starts(with: "-")
  if isNegative {
    value = String(value.dropFirst(1))
  }

  var numericPart: String
  var radix: Int
  if value.starts(with: NumericPrefix.hexadecimal) {
    numericPart = String(value.dropFirst())
    radix = 16
  } else if value.starts(with: NumericPrefix.octal) {
    numericPart = String(value.dropFirst())
    radix = 8
  } else if value.starts(with: NumericPrefix.binary) {
    numericPart = String(value.dropFirst())
    radix = 2
  } else {
    numericPart = value
    radix = 10
  }

  if isNegative {
    guard let negativeValue: Int8 = Int8(numericPart, radix: radix) else {
      return nil
    }
    return UInt8(bitPattern: -negativeValue)
  }

  guard let numericValue = UInt8(numericPart, radix: radix) else {
    return nil
  }

  return numericValue
}
