import Foundation

private struct Filenames {
  static let metadata = "metadata.plist"
  static let gitignore = ".gitignore"
  static let rom = "rom.gb"
  static let disassembly = "disassembly"
  static let configurationDir = "configuration"
  static let scriptsDir = "scripts"
  static let macrosDir = "macros"
  static let globals = "globals.asm"
  static let dataTypes = "datatypes.asm"
  static let regions = "regions.asm"
}

/** A representation of a Windfish project that can be saved to and loaded from disk. */
public final class Project: CustomStringConvertible {
  init(scripts: [Project.Script] = [], macros: [Macro] = []) {
    self.scripts = scripts
    self.macros = macros
  }

  public var description: String {
    return """
Windfish project
Scripts: \(scripts.map { $0.name }.joined(separator: ", "))
Macros: \(macros.map { $0.name }.joined(separator: ", "))
"""
  }

  var scripts: [Script] = []
  var macros: [Macro] = []

  public static func load(from url: URL) -> Project {
    let configurationUrl: URL = url.appendingPathComponent(Filenames.configurationDir)
    let scripts: [Script] = loadScripts(from: configurationUrl.appendingPathComponent(Filenames.scriptsDir))
    let macros: [Macro] = loadMacros(from: configurationUrl.appendingPathComponent(Filenames.macrosDir))
    return Project(scripts: scripts, macros: macros)
  }

  private static func loadScripts(from url: URL) -> [Script] {
    let fm = FileManager.default
    return ((try? fm.contentsOfDirectory(atPath: url.path)) ?? [])
      .compactMap { (filename: String) -> Script? in
        guard let data: Data = fm.contents(atPath: url.appendingPathComponent(filename).path) else {
          return nil
        }
        return Script(name: URL(fileURLWithPath: filename).deletingPathExtension().lastPathComponent,
                      source: String(data: data, encoding: .utf8)!)
      }
  }

  private static func loadMacros(from url: URL) -> [Macro] {
    let fm = FileManager.default
    return ((try? fm.contentsOfDirectory(atPath: url.path)) ?? [])
      .compactMap { (filename: String) -> Macro? in
        guard let data: Data = fm.contents(atPath: url.appendingPathComponent(filename).path) else {
          return nil
        }
        return Macro(name: URL(fileURLWithPath: filename).deletingPathExtension().lastPathComponent,
                     source: String(data: data, encoding: .utf8)!)
      }
  }
}
