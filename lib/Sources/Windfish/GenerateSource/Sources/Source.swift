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

      public func asData() -> Data? {
        switch self {
        case let .charmap(content: content): fallthrough
        case let .datatypes(content: content): fallthrough
        case let .game(content: content): fallthrough
        case let .macros(content: content): fallthrough
        case let .makefile(content: content): fallthrough
        case let .variables(content: content): fallthrough
        case let .bank(_, content, _):
          return content.data(using: .utf8)
        }
      }
    }
    public let sources: [String: FileDescription]
  }
}
