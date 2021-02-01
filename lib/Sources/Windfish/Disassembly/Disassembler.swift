import Foundation

import os.log

import RGBDS

extension LR35902.Instruction.Spec: InstructionSpecDisassemblyInfo {
  var category: InstructionCategory? {
    switch self {
    case .call: return .call
    case .ret, .reti: return .ret
    default: return nil
    }
  }
}

// TODO: Rename something like "ConfigurationInput".
protocol DisassemblerContext: class {
  var cartridgeData: Data { get }
  var numberOfBanks: Int { get }

  func allPotentialCode() -> Set<Range<Cartridge.Location>>
  func allPotentialText() -> Set<Range<Cartridge.Location>>
  func allPotentialData() -> Set<Range<Cartridge.Location>>

  func preComment(at location: Cartridge.Location) -> String?

  func allDataFormats() -> [Disassembler.Configuration.DataFormat: IndexSet]
  func formatOfData(at location: Cartridge.Location) -> Disassembler.Configuration.DataFormat?

  func datatypeExists(named name: String) -> Bool
  func datatype(named name: String) -> Disassembler.Configuration.Datatype?
  func allDatatypes() -> [String: Disassembler.Configuration.Datatype]

  func shouldTerminateLinearSweep(at location: Cartridge.Location) -> Bool

  func global(at address: LR35902.Address) -> Disassembler.Configuration.Global?
  func allGlobals() -> [LR35902.Address: Disassembler.Configuration.Global]

  func allScripts() -> [String: Disassembler.Configuration.Script]

  func allMappedCharacters() -> [UInt8: String]

  func macroTreeRoot() -> Disassembler.Configuration.MacroNode

  func label(at location: Cartridge.Location) -> String?

  func lineLengthOfText(at location: Cartridge.Location) -> Int?

  func bankChange(at location: Cartridge.Location) -> Cartridge.Bank?
}

/// A class that owns and manages disassembly information for a given ROM.
public final class Disassembler {

  public final class Configuration: DisassemblerContext {
    let cartridgeData: Data
    let numberOfBanks: Int

    init(cartridgeData: Data, numberOfBanks: Int) {
      self.cartridgeData = cartridgeData
      self.numberOfBanks = numberOfBanks
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

  public let mutableConfiguration: Configuration
  var configuration: DisassemblerContext {
    return mutableConfiguration
  }

  let cartridgeData: Data
  let cartridgeSize: Cartridge.Length
  public let numberOfBanks: Cartridge.Bank
  public init(data: Data) {
    self.cartridgeData = data
    self.cartridgeSize = Cartridge.Length(data.count)
    self.numberOfBanks = Cartridge.Bank(truncatingIfNeeded: (cartridgeSize + 0x4000 - 1) / 0x4000)
    self.mutableConfiguration = Configuration(cartridgeData: data, numberOfBanks: Int(truncatingIfNeeded: numberOfBanks))
  }

  var lastBankRouter: BankRouter?

  public func disassemble() {
    let log = OSLog(subsystem: "com.featherless.windfish", category: "PointsOfInterest")
    let signpostID = OSSignpostID(log: log)
    os_signpost(.begin, log: log, name: "Disassembler", signpostID: signpostID, "%{public}s", "disassemble")

    for range in configuration.allPotentialCode().sorted(by: { (a: Range<Cartridge.Location>, b: Range<Cartridge.Location>) -> Bool in
      a.lowerBound < b.lowerBound
    }) {
      let run = Run(from: range.lowerBound.address, selectedBank: range.lowerBound.bank, upTo: range.upperBound.address,
                    numberOfBanks: Int(truncatingIfNeeded: numberOfBanks))
      lastBankRouter!.schedule(run: run)
    }

    lastBankRouter!.finish()

    for (address, _) in configuration.allGlobals() {
      if address < 0x4000 {
        let location = Cartridge.Location(address: address, bank: 0x01)
        lastBankRouter!.registerRegion(range: location..<(location + 1), as: .data)
      }
    }

    for range: Range<Cartridge.Location> in configuration.allPotentialData() {
      lastBankRouter!.registerRegion(range: range, as: .data)
    }

    for range: Range<Cartridge.Location> in configuration.allPotentialText() {
      lastBankRouter!.registerRegion(range: range, as: .text)
    }
    os_signpost(.end, log: log, name: "Disassembler", signpostID: signpostID, "%{public}s", "disassemble")
  }

  /** Returns the label at the given location, if any. */
  public func labeledContiguousScopes(at location: Cartridge.Location) -> [String] {
    return lastBankRouter!.labeledContiguousScopes(at: location)
  }
}
