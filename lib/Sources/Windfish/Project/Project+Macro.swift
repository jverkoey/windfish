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

  static func loadMacros(from url: URL) -> [Macro] {
    let fm = FileManager.default
    return ((try? fm.contentsOfDirectory(atPath: url.path)) ?? []).compactMap { (filename: String) -> Macro? in
      guard let source: String = try? String(contentsOf: url.appendingPathComponent(filename), encoding: .utf8) else {
        return nil
      }
      return Macro(name: URL(fileURLWithPath: filename).deletingPathExtension().lastPathComponent, source: source)
    }
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
