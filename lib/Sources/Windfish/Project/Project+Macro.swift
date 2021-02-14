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
    guard let source = String(data: data, encoding: .utf8) else {
      return nil
    }
    return Macro(name: name, source: source)
  }

  func saveMacros(to url: URL) throws {
    for macro: Macro in macros {
      let macroUrl: URL = url.appendingPathComponent(macro.name).appendingPathExtension("asm")
      try macro.source.write(to: macroUrl, atomically: true, encoding: .utf8)
    }
  }

  func applyMacros(to configuration: Disassembler.MutableConfiguration) {
    for macro: Macro in macros {
      configuration.registerMacro(named: macro.name, template: macro.source)
    }
  }
}
