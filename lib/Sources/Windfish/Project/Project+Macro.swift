import Foundation

extension Project {
  final class Macro: NSObject {
    init(name: String, source: String) {
      self.name = name
      self.source = source
    }

    var name: String
    var source: String
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

  func applyMacros(to configuration: Disassembler.MutableConfiguration) {
    for macro: Macro in macros {
      configuration.registerMacro(named: macro.name, template: macro.source)
    }
  }
}
