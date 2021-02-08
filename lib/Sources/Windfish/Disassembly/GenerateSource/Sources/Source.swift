import Foundation

import Tracing

extension Disassembler {
  /** The potential types of source the disassembler can generate. */
  public struct Source {
    public enum FileDescription {
      case charmap(content: String)
      case datatypes(content: String)
      case game(content: String)
      case macros(content: String)
      case makefile(content: String)
      case variables(content: String)
      case bank(number: Cartridge.Bank, content: String, lines: [Line])
    }
    public let sources: [String: FileDescription]
  }
}
