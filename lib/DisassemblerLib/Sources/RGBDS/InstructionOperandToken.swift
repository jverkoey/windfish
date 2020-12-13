import Foundation

import FoundationExtensions

/** An operand token represents one operand of an instruction in RGBDS assembly. */
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
    if isNumber(string) {
      self = .numeric
      return
    }

    if string.hasPrefix("[") && string.hasSuffix("]") {
      let withinBrackets = String(string.dropFirst().dropLast())
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
  return
    string.hasPrefix(NumericPrefix.hexadecimal.rawValue)
    || string.hasPrefix(NumericPrefix.octal.rawValue)
    || string.hasPrefix(NumericPrefix.binary.rawValue)
    || string.hasPrefix(NumericPrefix.placeholder.rawValue)
    || string.hasPrefix(NumericPrefix.gameboyGraphics.rawValue)
    || (string.hasPrefix("-") && isNumber(String(string.dropFirst())))
    || Int(string) != nil
    || (string.contains(".") && Float(string) != nil)
}

// MARK: - RGBDS string -> number conversions

/**
 Enables generic methods to create Foundation integers from bit pattern representations.

 Foundation integer types already implement the bitPattern initializer, but this initializer is
 not exposed via any generic protocols. This protocol exposes the fact that those initializers
 exist on Foundation types.
 */
public protocol BitPatternInitializable {
  associatedtype CompanionType: FixedWidthInteger, SignedInteger
  init(bitPattern x: CompanionType)
}

extension UInt16: BitPatternInitializable {
  public typealias CompanionType = Int16
}

extension UInt8: BitPatternInitializable {
  public typealias CompanionType = Int8
}

public func integer<T: UnsignedInteger>(fromAddress string: String) -> T?
    where T: FixedWidthInteger,
          T: BitPatternInitializable {
  return integer(from: String(string.dropFirst().dropLast().trimmed()))
}

public func integer<T: UnsignedInteger>(fromStackPointer string: String) -> T?
where T: FixedWidthInteger,
      T: BitPatternInitializable {
  return integer(from: String(string.dropFirst(3).trimmed()))
}

public func integer<T: UnsignedInteger>(from string: String) -> T?
    where T: FixedWidthInteger,
          T: BitPatternInitializable {
  var value = string
  let isNegative = value.starts(with: "-")
  if isNegative {
    value = String(value.dropFirst(1))
  }

  var numericPart: String
  var radix: Int
  if value.starts(with: NumericPrefix.hexadecimal.rawValue) {
    numericPart = String(value.dropFirst())
    radix = 16
  } else if value.starts(with: NumericPrefix.octal.rawValue) {
    numericPart = String(value.dropFirst())
    radix = 8
  } else if value.starts(with: NumericPrefix.binary.rawValue) {
    numericPart = String(value.dropFirst())
    radix = 2
  } else {
    numericPart = value
    radix = 10
  }

  if isNegative {
    guard let negativeValue = T.CompanionType(numericPart, radix: radix) else {
      return nil
    }
    return T(bitPattern: -negativeValue)
  }

  guard let numericValue = T(numericPart, radix: radix) else {
    return nil
  }

  return numericValue
}
