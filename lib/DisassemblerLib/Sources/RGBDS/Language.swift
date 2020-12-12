import Foundation

/**
 Prefixes for numeric types in RGBDS assembly.

 Defined at https://rgbds.gbdev.io/docs/v0.4.2/rgbasm.5#Numeric_Formats
 */
enum NumericPrefix: String {
  case hexadecimal = "$"
  case octal = "&"
  case binary = "%"
  case placeholder = "#"
  case gameboyGraphics = "`"
}

/** The quote character used in RGBDS assembly. */
let quoteCharacter = "\""

/** The opcode used for representing data in RGBDS assembly. */
let dataOpcode = "db"
