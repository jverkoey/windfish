import Foundation

/**
 Prefixes for numeric types in RGBDS assembly.

 Defined at https://rgbds.gbdev.io/docs/v0.4.2/rgbasm.5#Numeric_Formats
 */
public enum NumericPrefix: String {
  case hexadecimal = "$"
  case octal = "&"
  case binary = "%"
  case placeholder = "#"
  case gameboyGraphics = "`"
}

/** Returns the given immediate as a hexadecimal representation in RGBDS assembly. */
public func asHexString<T: FixedWidthInteger>(_ imm: T) -> String {
  return NumericPrefix.hexadecimal.rawValue + imm.hexString
}

/** Returns the given immediate as a hexadecimal address representation in RGBDS assembly. */
public func asHexAddressString<T: FixedWidthInteger>(_ imm: T) -> String {
  return "[" + asHexString(imm) + "]"
}

/** The quote character used in RGBDS assembly. */
let quoteCharacter = "\""

/** The opcode used for representing data in RGBDS assembly. */
let dataOpcode = "db"
