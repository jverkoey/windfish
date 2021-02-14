import Foundation

extension Project {
  public final class Macro: NSObject {
    public init(name: String, source: String) {
      self.name = name
      self.source = source
    }

    public var name: String
    public var source: String
  }

  static public func loadMacro(from data: Data, with name: String) -> Macro? {
    guard let source: String = String(data: data, encoding: .utf8) else {
      return nil
    }
    return Macro(name: name, source: source)
  }

  public func macrosAsData() -> [String: Data] {
    return macros.reduce(into: [:], { (accumulator, macro) in
      accumulator["\(macro.name).asm"] = macro.source.data(using: .utf8)
    })
  }

  func applyMacros(to configuration: Disassembler.MutableConfiguration) {
    for macro: Macro in macros {
      configuration.registerMacro(named: macro.name, template: macro.source)
    }
  }
}
