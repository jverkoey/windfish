import Foundation

import Tracing

/** A representation of a Windfish project that can be saved to and loaded from disk. */
public final class Project: CustomStringConvertible {
  public init(rom: Data?, scripts: [Project.Script] = [], macros: [Macro] = [], globals: [Global] = [], dataTypes: [DataType] = [], regions: [Region] = []) {
    self.rom = rom
    self.scripts = scripts
    self.macros = macros
    self.globals = globals
    self.dataTypes = dataTypes
    self.regions = regions
  }

  public struct Filenames {
    public static let metadata = "metadata.plist"
    public static let gitignore = ".gitignore"
    public static let rom = "rom.gb"
    public static let disassembly = "disassembly"
    public static let configurationDir = "configuration"
    public static let scriptsDir = "scripts"
    public static let macrosDir = "macros"
    public static let globals = "globals.asm"
    public static let dataTypes = "datatypes.asm"
    public static let regions = "regions.asm"
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

  public var rom: Data?
  public var scripts: [Script] = []
  public var macros: [Macro] = []
  public var globals: [Global] = []
  public var dataTypes: [DataType] = []
  public var regions: [Region] = []

  public static func load(from url: URL) throws -> Project {
    let fm = FileManager.default

    let configurationUrl: URL = url.appendingPathComponent(Filenames.configurationDir)
    let macrosUrl: URL = configurationUrl.appendingPathComponent(Filenames.macrosDir)
    let scriptsUrl: URL = configurationUrl.appendingPathComponent(Filenames.scriptsDir)

    let rom: Data = try Data(contentsOf: url.appendingPathComponent(Filenames.rom))

    let scripts: [Script]
    if let filenames = try? fm.contentsOfDirectory(atPath: scriptsUrl.path) {
      scripts = filenames.compactMap { (filename: String) -> Script? in
        guard let data: Data = try? Data(contentsOf: scriptsUrl.appendingPathComponent(filename)) else {
          return nil
        }
        return loadScript(from: data, with: URL(fileURLWithPath: filename).deletingPathExtension().lastPathComponent)
      }
    } else {
      scripts = []
    }

    let macros: [Macro]
    if let filenames = try? fm.contentsOfDirectory(atPath: macrosUrl.path) {
      macros = filenames.compactMap { (filename: String) -> Macro? in
        guard let data: Data = try? Data(contentsOf: macrosUrl.appendingPathComponent(filename)) else {
          return nil
        }
        return loadMacro(from: data, with: URL(fileURLWithPath: filename).deletingPathExtension().lastPathComponent)
      }
    } else {
      macros = []
    }

    let globals: [Global]
    if let data = try? Data(contentsOf: configurationUrl.appendingPathComponent(Filenames.globals)) {
      globals = loadGlobals(from: data)
    } else {
      globals = []
    }

    let dataTypes: [DataType]
    if let data = try? Data(contentsOf: configurationUrl.appendingPathComponent(Filenames.dataTypes)) {
      dataTypes = loadDataTypes(from: data)
    } else {
      dataTypes = []
    }

    let regions: [Region]
    if let data = try? Data(contentsOf: configurationUrl.appendingPathComponent(Filenames.regions)) {
      regions = loadRegions(from: data)
    } else {
      regions = []
    }

    return Project(rom: rom, scripts: scripts, macros: macros, globals: globals, dataTypes: dataTypes, regions: regions)
  }

  /** Returns true if the save succeeded, false if it failed. */
  public func save(to url: URL) throws {
    let configurationUrl: URL = url.appendingPathComponent(Filenames.configurationDir)
    let scriptsUrl: URL = configurationUrl.appendingPathComponent(Filenames.scriptsDir)
    let macrosUrl: URL = configurationUrl.appendingPathComponent(Filenames.macrosDir)
    let fm: FileManager = FileManager.default
    try fm.createDirectory(at: configurationUrl, withIntermediateDirectories: true, attributes: nil)
    if fm.fileExists(atPath: scriptsUrl.path) {
      try fm.removeItem(at: scriptsUrl)
    }
    if fm.fileExists(atPath: macrosUrl.path) {
      try fm.removeItem(at: macrosUrl)
    }
    try fm.createDirectory(at: scriptsUrl, withIntermediateDirectories: true, attributes: nil)
    try fm.createDirectory(at: macrosUrl, withIntermediateDirectories: true, attributes: nil)

    try rom?.write(to: url.appendingPathComponent(Filenames.rom))
    try gitignoreAsData().write(to: url.appendingPathComponent(Filenames.gitignore))

    try scriptsAsData().forEach { (key: String, value: Data) in
      try value.write(to: scriptsUrl.appendingPathComponent(key))
    }
    try macrosAsData().forEach { (key: String, value: Data) in
      try value.write(to: macrosUrl.appendingPathComponent(key))
    }
    try globalsAsData().write(to: configurationUrl.appendingPathComponent(Filenames.globals))
    try dataTypesAsData().write(to: configurationUrl.appendingPathComponent(Filenames.dataTypes))
    try regionsAsData().write(to: configurationUrl.appendingPathComponent(Filenames.regions))
  }

  public func gitignoreAsData() -> Data {
    return """
rom.gb
disassembly/game.gb
disassembly/game.map
disassembly/game.o
disassembly/game.sym
""".data(using: .utf8)!
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
