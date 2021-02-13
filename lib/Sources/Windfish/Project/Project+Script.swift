import Foundation

extension Project {
  final class Script: NSObject {
    init(name: String, source: String) {
      self.name = name
      self.source = source
    }

    var name: String
    var source: String
  }

  static func loadScripts(from url: URL) -> [Script] {
    let fm = FileManager.default
    return ((try? fm.contentsOfDirectory(atPath: url.path)) ?? [])
      .compactMap { (filename: String) -> Script? in
        guard let source: String = try? String(contentsOf: url.appendingPathComponent(filename), encoding: .utf8) else {
          return nil
        }
        return Script(name: URL(fileURLWithPath: filename).deletingPathExtension().lastPathComponent, source: source)
      }
  }

  func prepareScripts(in configuration: Disassembler.MutableConfiguration) {
    // Integrate scripts before any disassembly in order to allow the scripts to modify the disassembly runs.
    for script: Script in scripts {
      configuration.registerScript(named: script.name, source: script.source)
    }
  }
}
