import Foundation

extension Project {
  public final class Script: NSObject {
    public init(name: String, source: String) {
      self.name = name
      self.source = source
    }

    public var name: String
    public var source: String
  }

  static public func loadScript(from data: Data, with name: String) -> Script? {
    guard let source: String = String(data: data, encoding: .utf8) else {
      return nil
    }
    return Script(name: name, source: source)
  }

  func saveScripts(to url: URL) throws {
    for script: Script in scripts {
      let scriptUrl: URL = url.appendingPathComponent(script.name).appendingPathExtension("js")
      try script.source.write(to: scriptUrl, atomically: true, encoding: .utf8)
    }
  }

  func prepareScripts(in configuration: Disassembler.MutableConfiguration) {
    // Integrate scripts before any disassembly in order to allow the scripts to modify the disassembly runs.
    for script: Script in scripts {
      configuration.registerScript(named: script.name, source: script.source)
    }
  }
}
