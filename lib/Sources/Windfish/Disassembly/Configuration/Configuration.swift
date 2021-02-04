import Foundation

protocol Configuration: class {
  var cartridgeData: Data { get }
  var numberOfBanks: Int { get }

  func allPotentialCode() -> Set<Range<Cartridge.Location>>
  func allPotentialText() -> Set<Range<Cartridge.Location>>
  func allPotentialData() -> Set<Range<Cartridge.Location>>

  func preComment(at location: Cartridge.Location) -> String?

  func allDataFormats() -> [Disassembler.MutableConfiguration.DataFormat: IndexSet]
  func formatOfData(at location: Cartridge.Location) -> Disassembler.MutableConfiguration.DataFormat?

  func datatypeExists(named name: String) -> Bool
  func datatype(named name: String) -> Disassembler.MutableConfiguration.Datatype?
  func allDatatypes() -> [String: Disassembler.MutableConfiguration.Datatype]

  func shouldTerminateLinearSweep(at location: Cartridge.Location) -> Bool

  func global(at address: LR35902.Address) -> Disassembler.MutableConfiguration.Global?
  func allGlobals() -> [LR35902.Address: Disassembler.MutableConfiguration.Global]

  func allScripts() -> [String: Disassembler.MutableConfiguration.Script]

  func allMappedCharacters() -> [UInt8: String]

  func macroTreeRoot() -> Disassembler.MutableConfiguration.MacroNode

  func label(at location: Cartridge.Location) -> String?

  func lineLengthOfText(at location: Cartridge.Location) -> Int?

  func bankChange(at location: Cartridge.Location) -> Cartridge.Bank?
}

/// A class that owns and manages disassembly information for a given ROM.
extension Disassembler {

  public final class MutableConfiguration: Configuration {
    let cartridgeData: Data
    public let numberOfBanks: Int

    init(cartridgeData: Data) {
      self.cartridgeData = cartridgeData
      let cartridgeSize: Int = cartridgeData.count
      self.numberOfBanks = (cartridgeSize + 0x4000 - 1) / 0x4000
    }

    /** Ranges of executable regions that should be disassembled. */
    var executableRegions = Set<Range<Cartridge.Location>>()

    /** Ranges of cartridge locations that could represent text. */
    var potentialText = Set<Range<Cartridge.Location>>()

    /** Ranges of cartridge locations that could represent data. */
    var potentialData = Set<Range<Cartridge.Location>>()

    /** Comments that should be placed immediately before the given location. */
    var preComments: [Cartridge.Location: String] = [:]

    /** Registered data types. */
    var dataTypes: [String: Datatype] = [:]

    /** Named regions of memory that can be read as data. */
    var globals: [LR35902.Address: Global] = [:]

    /** The names of specific locations in the cartridge. */
    var labelNames: [Cartridge.Location: String] = [:]

    /** When a soft terminator is encountered during linear sweep the sweep will immediately end. */
    var softTerminators: [Cartridge.Location: Bool] = [:]

    /** Scripts that should be executed alongside the disassembler. */
    var scripts: [String: Script] = [:]

    /** Character codes mapped to strings. */
    var characterMap: [UInt8: String] = [:]

    /** Bank changes that occur at a specific location. */
    var bankChanges: [Cartridge.Location: Cartridge.Bank] = [:]

    /** Locations that can transfer control (jp/call) to a specific location. */
    var transfers: [Cartridge.Location: Set<Cartridge.Location>] = [:]

    /**
     Macros are stored in a tree, where each edge is a representation of an instruction and the leaf nodes are the macro
     implementation.
     */
    let macroTree = MacroNode()

    /** The maximum length of a line of text within a given range. */
    var textLengths: [Range<Cartridge.Location>: Int] = [:]

    /** The format of the data at specific locations. */
    var dataFormats: [DataFormat: IndexSet] = [:]
  }
}
