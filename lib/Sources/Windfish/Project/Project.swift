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
  init(scripts: [Project.Script] = [], macros: [Macro] = [], globals: [Global] = []) {
    self.scripts = scripts
    self.macros = macros
    self.globals = globals
  }

  public var description: String {
    return """
Windfish project
Scripts: \(scripts.map { $0.name }.joined(separator: ", "))
Macros: \(macros.map { $0.name }.joined(separator: ", "))
Globals: \(globals.map { $0.name }.joined(separator: ", "))
"""
  }

  var scripts: [Script] = []
  var macros: [Macro] = []
  var globals: [Global] = []

  public static func load(from url: URL) -> Project {
    let configurationUrl: URL = url.appendingPathComponent(Filenames.configurationDir)
    let scripts: [Script] = loadScripts(from: configurationUrl.appendingPathComponent(Filenames.scriptsDir))
    let macros: [Macro] = loadMacros(from: configurationUrl.appendingPathComponent(Filenames.macrosDir))
    let globals: [Global] = loadGlobals(from: configurationUrl.appendingPathComponent(Filenames.globals))
    return Project(scripts: scripts, macros: macros, globals: globals)
  }
}
