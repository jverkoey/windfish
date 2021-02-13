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

  var scripts: [Script] = []
  var macros: [Macro] = []
  var globals: [Global] = []
  var dataTypes: [DataType] = []
  var regions: [Region] = []

  public static func load(from url: URL) -> Project {
    let configurationUrl: URL = url.appendingPathComponent(Filenames.configurationDir)
    let scripts: [Script] = loadScripts(from: configurationUrl.appendingPathComponent(Filenames.scriptsDir))
    let macros: [Macro] = loadMacros(from: configurationUrl.appendingPathComponent(Filenames.macrosDir))
    let globals: [Global] = loadGlobals(from: configurationUrl.appendingPathComponent(Filenames.globals))
    let dataTypes: [DataType] = loadDataTypes(from: configurationUrl.appendingPathComponent(Filenames.dataTypes))
    let regions: [Region] = loadRegions(from: configurationUrl.appendingPathComponent(Filenames.regions))
    return Project(scripts: scripts, macros: macros, globals: globals, dataTypes: dataTypes, regions: regions)
  }

  public func prepare(_ configuration: Disassembler.MutableConfiguration) {
    // Integrate scripts before any disassembly in order to allow the scripts to modify the disassembly runs.
    for script: Script in scripts {
      configuration.registerScript(named: script.name, source: script.source)
    }
  }

  public func apply(to configuration: Disassembler.MutableConfiguration) {
    for dataType: DataType in dataTypes {
      let mappingDict: [UInt8: String] = dataType.mappings.reduce(into: [:]) { accumulator, mapping in
        accumulator[mapping.value] = mapping.name
      }
      let representation: Disassembler.MutableConfiguration.Datatype.Representation
      switch dataType.representation {
      case DataType.Representation.binary:
        representation = .binary
      case DataType.Representation.decimal:
        representation = .decimal
      case DataType.Representation.hexadecimal:
        representation = .hexadecimal
      default:
        preconditionFailure()
      }
      switch dataType.interpretation {
      case DataType.Interpretation.any:
        configuration.registerDatatype(named: dataType.name, representation: representation)
      case DataType.Interpretation.bitmask:
        configuration.createDatatype(named: dataType.name, bitmask: mappingDict, representation: representation)
      case DataType.Interpretation.enumerated:
        configuration.createDatatype(named: dataType.name, enumeration: mappingDict, representation: representation)
      default:
        preconditionFailure()
      }
    }

    for global: Global in globals {
      configuration.registerGlobal(at: global.address, named: global.name, dataType: global.dataType)
    }

    for region: Region in regions {
      let location = Cartridge.Location(address: region.address, bank: region.bank)
      switch region.regionType {
      case Region.Kind.region:
        configuration.registerPotentialCode(at: location..<(location + region.length), named: region.name)

      case Region.Kind.function:
        configuration.registerFunction(startingAt: location, named: region.name)

      case Region.Kind.label:
        configuration.registerLabel(at: location, named: region.name)

      case Region.Kind.string:
        configuration.registerLabel(at: location, named: region.name)
        let startLocation = Cartridge.Location(address: region.address, bank: region.bank)
        configuration.registerText(at: startLocation..<(startLocation + region.length), lineLength: nil)

      case Region.Kind.image1bpp:
        configuration.registerLabel(at: location, named: region.name)
        let startLocation = Cartridge.Location(address: region.address, bank: location.bank)
        configuration.registerData(at: startLocation..<(startLocation + region.length), format: .image1bpp)

      case Region.Kind.image2bpp:
        configuration.registerLabel(at: location, named: region.name)
        let startLocation = Cartridge.Location(address: region.address, bank: location.bank)
        configuration.registerData(at: startLocation..<(startLocation + region.length), format: .image2bpp)

      case Region.Kind.data:
        configuration.registerLabel(at: location, named: region.name)
        let startLocation = Cartridge.Location(address: region.address, bank: location.bank)
        configuration.registerData(at: startLocation..<(startLocation + region.length))

      default:
        break
      }
    }

    for macro: Macro in macros {
      configuration.registerMacro(named: macro.name, template: macro.source)
    }
  }
}
