import Foundation

import Tracing

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
  init(scripts: [Project.Script] = [], macros: [Macro] = [], globals: [Global] = [], dataTypes: [DataType] = [], regions: [Region] = []) {
    self.scripts = scripts
    self.macros = macros
    self.globals = globals
    self.dataTypes = dataTypes
    self.regions = regions
  }

  public var description: String {
    return """
Windfish project
Scripts: \(scripts.map { $0.name }.joined(separator: ", "))
Macros: \(macros.map { $0.name }.joined(separator: ", "))
Globals: \(globals.map { $0.name }.joined(separator: ", "))
Data types: \(dataTypes.map { $0.name }.joined(separator: ", "))
Regions: \(regions.map { $0.name }.joined(separator: ", "))
"""
  }

  public var scripts: [Script] = []
  public var macros: [Macro] = []
  public var globals: [Global] = []
  public var dataTypes: [DataType] = []
  public var regions: [Region] = []

  public static func load(from url: URL) -> Project {
    let configurationUrl: URL = url.appendingPathComponent(Filenames.configurationDir)
    let scripts: [Script] = loadScripts(from: configurationUrl.appendingPathComponent(Filenames.scriptsDir))
    let macros: [Macro] = loadMacros(from: configurationUrl.appendingPathComponent(Filenames.macrosDir))
    let globals: [Global] = loadGlobals(from: configurationUrl.appendingPathComponent(Filenames.globals))
    let dataTypes: [DataType] = loadDataTypes(from: configurationUrl.appendingPathComponent(Filenames.dataTypes))
    let regions: [Region] = loadRegions(from: configurationUrl.appendingPathComponent(Filenames.regions))
    return Project(scripts: scripts, macros: macros, globals: globals, dataTypes: dataTypes, regions: regions)
  }

  /** Returns true if the save succeeded, false if it failed. */
  public func save(to url: URL) throws -> Bool {
    let configurationUrl: URL = url.appendingPathComponent(Filenames.configurationDir)
    let scriptsUrl: URL = configurationUrl.appendingPathComponent(Filenames.scriptsDir)
    let macrosUrl: URL = configurationUrl.appendingPathComponent(Filenames.macrosDir)
    let fm: FileManager = FileManager.default
    try fm.createDirectory(at: configurationUrl, withIntermediateDirectories: true, attributes: nil)
    try fm.removeItem(at: scriptsUrl)
    try fm.removeItem(at: macrosUrl)
    try fm.createDirectory(at: scriptsUrl, withIntermediateDirectories: true, attributes: nil)
    try fm.createDirectory(at: macrosUrl, withIntermediateDirectories: true, attributes: nil)

    try saveScripts(to: scriptsUrl)
    try saveMacros(to: macrosUrl)
    try saveGlobals(to: configurationUrl.appendingPathComponent(Filenames.globals))
    try saveDataTypes(to: configurationUrl.appendingPathComponent(Filenames.dataTypes))
    try saveRegions(to: configurationUrl.appendingPathComponent(Filenames.regions))

    return true
  }

  public func prepare(_ configuration: Disassembler.MutableConfiguration) {
    prepareScripts(in: configuration)
  }

  public func apply(to configuration: Disassembler.MutableConfiguration) {
    applyDataTypes(to: configuration)
    applyGlobals(to: configuration)
    applyRegions(to: configuration)
    applyMacros(to: configuration)
  }
}
