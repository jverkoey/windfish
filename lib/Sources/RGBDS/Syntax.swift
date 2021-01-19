import Foundation

/**
 Prefixes for numeric types in RGBDS assembly.

 Defined at https://rgbds.gbdev.io/docs/v0.4.2/rgbasm.5#Numeric_Formats
 */
public struct NumericPrefix {
  public static let hexadecimal: String = "$"
  public static let octal: String = "&"
  public static let binary: String = "%"
  public static let placeholder: String = "#"
  public static let gameboyGraphics: String = "`"
}

public struct Symbol {
  /** The quote character used in RGBDS assembly. */
  public static let quoteCharacter = "\""

  /** The opcode used for representing data in RGBDS assembly. */
  public static let dataOpcode = "db"

  /** In mathematical expressions, represents the current program counter. */
  public static let pc = "@"
}

/** Returns the given immediate as a decimal representation in RGBDS assembly. */
public func asDecimalString<T: FixedWidthInteger>(_ imm: T) -> String {
  return "\(imm)"
}

/** Returns the given immediate as a binary representation in RGBDS assembly. */
public func asBinaryString<T: FixedWidthInteger>(_ imm: T) -> String {
  return NumericPrefix.binary + imm.binaryString
}

/** Returns the given immediate as a hexadecimal representation in RGBDS assembly. */
public func asHexString<T: FixedWidthInteger>(_ imm: T) -> String {
  return NumericPrefix.hexadecimal + imm.hexString
}

/** Returns the given immediate as a hexadecimal address representation in RGBDS assembly. */
public func asHexAddressString<T: FixedWidthInteger>(_ imm: T) -> String {
  return "[" + asHexString(imm) + "]"
}
