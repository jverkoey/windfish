//
//  Document.swift
//  gbdis
//
//  Created by Jeff Verkoeyen on 11/30/20.
//

import Cocoa

import LR35902
import RGBDS

final class Region: NSObject, Codable {
  struct Kind {
    static let region = "Region"
    static let label = "Label"
    static let function = "Function"
    static let string = "String"
    static let data = "Data"
    static let image1bpp = "Image (1bpp)"
    static let image2bpp = "Image (2bpp)"
  }
  @objc dynamic var regionType: String {
    didSet {
      if regionType == Kind.label || regionType == Kind.function {
        length = 0
      }
    }
  }
  @objc dynamic var name: String
  @objc dynamic var bank: LR35902.Bank
  @objc dynamic var address: LR35902.Address
  @objc dynamic var length: LR35902.Address

  init(regionType: String, name: String, bank: LR35902.Bank, address: LR35902.Address, length: LR35902.Address) {
    self.regionType = regionType
    self.name = name
    self.bank = bank
    self.address = address
    self.length = length
  }
}

final class DataType: NSObject, Codable {
  init(name: String, representation: String, interpretation: String, mappings: [Mapping]) {
    self.name = name
    self.representation = representation
    self.interpretation = interpretation
    self.mappings = mappings
  }

  struct Interpretation {
    static let any = "Any"
    static let enumerated = "Enumerated"
    static let bitmask = "Bitmask"
  }
  struct Representation {
    static let decimal = "Decimal"
    static let hexadecimal = "Hex"
    static let binary = "Binary"
  }

  final class Mapping: NSObject, Codable {
    internal init(name: String, value: UInt8) {
      self.name = name
      self.value = value
    }
    
    @objc dynamic var name: String
    @objc dynamic var value: UInt8
  }

  @objc dynamic var name: String
  @objc dynamic var representation: String
  @objc dynamic var interpretation: String
  @objc dynamic var mappings: [Mapping]
}

final class Global: NSObject, Codable {
  internal init(name: String, address: LR35902.Address, dataType: String) {
    self.name = name
    self.address = address
    self.dataType = dataType
  }

  @objc dynamic var name: String
  @objc dynamic var address: LR35902.Address
  @objc dynamic var dataType: String
}

final class Macro: NSObject, Codable {
  internal init(name: String, source: String) {
    self.name = name
    self.source = source
  }

  @objc dynamic var name: String
  @objc dynamic var source: String
}

class ProjectConfiguration: NSObject, Codable {
  @objc dynamic var regions: [Region] = []
  @objc dynamic var dataTypes: [DataType] = []
  @objc dynamic var globals: [Global] = []
  @objc dynamic var macros: [Macro] = []

  override init() {
    super.init()
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Self.CodingKeys)
    regions = (try? container.decode(Array<Region>.self, forKey: .regions)) ?? []
    dataTypes = (try? container.decode(Array<DataType>.self, forKey: .dataTypes)) ?? []
    globals = (try? container.decode(Array<Global>.self, forKey: .globals)) ?? []
    macros = (try? container.decode(Array<Macro>.self, forKey: .macros)) ?? []
  }
}

final class DisassemblyResults: NSObject {
  internal init(files: [String : Data], bankLines: [LR35902.Bank : [LR35902.Disassembly.Line]]? = nil, bankTextStorage: [LR35902.Bank: NSAttributedString]? = nil, regions: [Region]? = nil, regionLookup: [String: Region]? = nil, statistics: LR35902.Disassembly.Statistics? = nil) {
    self.files = files
    self.bankLines = bankLines
    self.bankTextStorage = bankTextStorage
    self.regions = regions
    self.regionLookup = regionLookup
    self.statistics = statistics
  }

  var files: [String: Data]
  var bankLines: [LR35902.Bank: [LR35902.Disassembly.Line]]?
  var bankTextStorage: [LR35902.Bank: NSAttributedString]?
  @objc dynamic var regions: [Region]?
  var regionLookup: [String: Region]?
  var statistics: LR35902.Disassembly.Statistics?
}

struct ProjectMetadata: Codable {
  var romUrl: URL
  var numberOfBanks: LR35902.Bank
  var bankMap: [String: LR35902.Bank]
}

private struct Filenames {
  static let metadata = "metadata.plist"
  static let rom = "rom.gb"
  static let disassembly = "disassembly"
  static let configuration = "configuration.plist"
}

@objc(ProjectDocument)
class ProjectDocument: NSDocument {
  weak var contentViewController: ProjectViewController?

  var isDisassembling = false
  var romData: Data?
  @objc dynamic var disassemblyResults: DisassemblyResults?
  var metadata: ProjectMetadata?
  var configuration = ProjectConfiguration()

  override init() {
    super.init()

    let numberOfRestartAddresses: LR35902.Address = 8
    let restartSize: LR35902.Address = 8
    let rstAddresses = (0..<numberOfRestartAddresses).map { ($0 * restartSize)..<($0 * restartSize + restartSize) }
    rstAddresses.forEach {
      configuration.regions.append(Region(regionType: Region.Kind.region, name: "RST_\($0.lowerBound.hexString)", bank: 0, address: $0.lowerBound, length: LR35902.Address($0.count)))
    }

    configuration.regions.append(contentsOf: [
      Region(regionType: Region.Kind.region, name: "VBlankInterrupt", bank: 0, address: 0x0040, length: 8),
      Region(regionType: Region.Kind.region, name: "LCDCInterrupt", bank: 0, address: 0x0048, length: 8),
      Region(regionType: Region.Kind.region, name: "TimerOverflowInterrupt", bank: 0, address: 0x0050, length: 8),
      Region(regionType: Region.Kind.region, name: "SerialTransferCompleteInterrupt", bank: 0, address: 0x0058, length: 8),
      Region(regionType: Region.Kind.region, name: "JoypadTransitionInterrupt", bank: 0, address: 0x0060, length: 8),
      Region(regionType: Region.Kind.region, name: "Boot", bank: 0, address: 0x0100, length: 4),
      Region(regionType: Region.Kind.image1bpp, name: "HeaderLogo", bank: 0, address: 0x0104, length: 0x0134 - 0x0104),
      Region(regionType: Region.Kind.string, name: "HeaderTitle", bank: 0, address: 0x0134, length: 0x0143 - 0x0134),
      Region(regionType: Region.Kind.label, name: "HeaderNewLicenseeCode", bank: 0, address: 0x0144, length: 0),
      Region(regionType: Region.Kind.label, name: "HeaderOldLicenseeCode", bank: 0, address: 0x014B, length: 0),
      Region(regionType: Region.Kind.label, name: "HeaderMaskROMVersion", bank: 0, address: 0x014C, length: 0),
      Region(regionType: Region.Kind.label, name: "HeaderComplementCheck", bank: 0, address: 0x014D, length: 0),
      Region(regionType: Region.Kind.label, name: "HeaderGlobalChecksum", bank: 0, address: 0x014E, length: 0),
    ])

    configuration.dataTypes.append(DataType(name: "hex",
                                            representation: DataType.Representation.hexadecimal,
                                            interpretation: DataType.Interpretation.any,
                                            mappings: []))
    configuration.dataTypes.append(DataType(name: "decimal",
                                            representation: DataType.Representation.decimal,
                                            interpretation: DataType.Interpretation.any,
                                            mappings: []))
    configuration.dataTypes.append(DataType(name: "binary",
                                            representation: DataType.Representation.binary,
                                            interpretation: DataType.Interpretation.any,
                                            mappings: []))
    configuration.dataTypes.append(DataType(name: "bool",
                                            representation: DataType.Representation.decimal,
                                            interpretation: DataType.Interpretation.enumerated,
                                            mappings: [
                                              DataType.Mapping(name: "false", value: 0),
                                              DataType.Mapping(name: "true", value: 1)
                                            ]))

    configuration.dataTypes.append(DataType(name: "HW_COLORGAMEBOY",
                                            representation: DataType.Representation.hexadecimal,
                                            interpretation: DataType.Interpretation.enumerated,
                                            mappings: [
                                              DataType.Mapping(name: "not_color_gameboy", value: 0x00),
                                              DataType.Mapping(name: "is_color_gameboy", value: 0x80),
                                            ]))
    configuration.dataTypes.append(DataType(name: "HW_SUPERGAMEBOY",
                                            representation: DataType.Representation.hexadecimal,
                                            interpretation: DataType.Interpretation.enumerated,
                                            mappings: [
                                              DataType.Mapping(name: "not_super_gameboy", value: 0x00),
                                              DataType.Mapping(name: "is_super_gameboy", value: 0x80),
                                            ]))
    configuration.dataTypes.append(DataType(name: "HW_ROMSIZE",
                                            representation: DataType.Representation.hexadecimal,
                                            interpretation: DataType.Interpretation.enumerated,
                                            mappings: [
                                              DataType.Mapping(name: "romsize_2banks", value: 0),
                                              DataType.Mapping(name: "romsize_4banks", value: 1),
                                              DataType.Mapping(name: "romsize_8banks", value: 2),
                                              DataType.Mapping(name: "romsize_16banks", value: 3),
                                              DataType.Mapping(name: "romsize_32banks", value: 4),
                                              DataType.Mapping(name: "romsize_64banks", value: 5),
                                              DataType.Mapping(name: "romsize_128banks", value: 6),
                                              DataType.Mapping(name: "romsize_72banks", value: 0x52),
                                              DataType.Mapping(name: "romsize_80banks", value: 0x53),
                                              DataType.Mapping(name: "romsize_96banks", value: 0x54),
                                            ]))
    configuration.dataTypes.append(DataType(name: "HW_CARTRIDGETYPE",
                                            representation: DataType.Representation.hexadecimal,
                                            interpretation: DataType.Interpretation.enumerated,
                                            mappings: [
                                              DataType.Mapping(name: "cartridge_romonly", value: 0),
                                              DataType.Mapping(name: "cartridge_mbc1", value: 1),
                                              DataType.Mapping(name: "cartridge_mbc1_ram", value: 2),
                                              DataType.Mapping(name: "cartridge_mbc1_ram_battery", value: 3),
                                              DataType.Mapping(name: "cartridge_mbc2", value: 5),
                                              DataType.Mapping(name: "cartridge_mbc2_battery", value: 6),
                                              DataType.Mapping(name: "cartridge_rom_ram", value: 8),
                                              DataType.Mapping(name: "cartridge_rom_ram_battery", value: 9),
                                            ]))
    configuration.dataTypes.append(DataType(name: "HW_RAMSIZE",
                                            representation: DataType.Representation.hexadecimal,
                                            interpretation: DataType.Interpretation.enumerated,
                                            mappings: [
                                              DataType.Mapping(name: "ramsize_none", value: 0),
                                              DataType.Mapping(name: "ramsize_1bank", value: 1),
                                              DataType.Mapping(name: "ramsize_1bank_", value: 2),
                                              DataType.Mapping(name: "ramsize_4banks", value: 3),
                                              DataType.Mapping(name: "ramsize_16banks", value: 4),
                                            ]))
    configuration.dataTypes.append(DataType(name: "HW_DESTINATIONCODE",
                                            representation: DataType.Representation.hexadecimal,
                                            interpretation: DataType.Interpretation.enumerated,
                                            mappings: [
                                              DataType.Mapping(name: "destination_japanese", value: 0),
                                              DataType.Mapping(name: "destination_nonjapanese", value: 1),
                                            ]))
    configuration.dataTypes.append(DataType(name: "HW_IE",
                                            representation: DataType.Representation.binary,
                                            interpretation: DataType.Interpretation.bitmask,
                                            mappings: [
                                              DataType.Mapping(name: "IE_VBLANK", value: 0b0000_0001),
                                              DataType.Mapping(name: "IE_LCDC", value: 0b0000_0010),
                                              DataType.Mapping(name: "IE_TIMEROVERFLOW", value: 0b0000_0100),
                                              DataType.Mapping(name: "IE_SERIALIO", value: 0b0000_1000),
                                              DataType.Mapping(name: "IE_PIN1013TRANSITION", value: 0b0001_0000),
                                            ]))
    configuration.dataTypes.append(DataType(name: "LCDCF",
                                            representation: DataType.Representation.binary,
                                            interpretation: DataType.Interpretation.bitmask,
                                            mappings: [
                                              DataType.Mapping(name: "LCDCF_OFF", value: 0b0000_0000),
                                              DataType.Mapping(name: "LCDCF_ON", value: 0b1000_0000),
                                              DataType.Mapping(name: "LCDCF_TILEMAP_9C00", value: 0b0100_0000),
                                              DataType.Mapping(name: "LCDCF_WINDOW_ON", value: 0b0010_0000),
                                              DataType.Mapping(name: "LCDCF_BG_CHAR_8000", value: 0b0001_0000),
                                              DataType.Mapping(name: "LCDCF_BG_TILE_9C00", value: 0b0000_1000),
                                              DataType.Mapping(name: "LCDCF_OBJ_16_16", value: 0b0000_0100),
                                              DataType.Mapping(name: "LCDCF_OBJ_DISPLAY", value: 0b0000_0010),
                                              DataType.Mapping(name: "LCDCF_BG_DISPLAY", value: 0b0000_0001),
                                            ]))
    configuration.dataTypes.append(DataType(name: "STATF",
                                            representation: DataType.Representation.binary,
                                            interpretation: DataType.Interpretation.bitmask,
                                            mappings: [
                                              DataType.Mapping(name: "STATF_LYC", value: 0b0100_0000),
                                              DataType.Mapping(name: "STATF_MODE10", value: 0b0010_0000),
                                              DataType.Mapping(name: "STATF_MODE01", value: 0b0001_0000),
                                              DataType.Mapping(name: "STATF_MODE00", value: 0b0000_1000),
                                              DataType.Mapping(name: "STATF_LYCF", value: 0b0000_0100),
                                              DataType.Mapping(name: "STATF_OAM", value: 0b0000_0010),
                                              DataType.Mapping(name: "STATF_VB", value: 0b0000_0001),
                                              DataType.Mapping(name: "STATF_HB", value: 0b0000_0000),
                                            ]))
    configuration.dataTypes.append(DataType(name: "BUTTON",
                                            representation: DataType.Representation.binary,
                                            interpretation: DataType.Interpretation.bitmask,
                                            mappings: [
                                              DataType.Mapping(name: "J_RIGHT", value: 0b0000_0001),
                                              DataType.Mapping(name: "J_LEFT", value: 0b0000_0010),
                                              DataType.Mapping(name: "J_UP", value: 0b0000_0100),
                                              DataType.Mapping(name: "J_DOWN", value: 0b0000_1000),
                                              DataType.Mapping(name: "J_A", value: 0b0001_0000),
                                              DataType.Mapping(name: "J_B", value: 0b0010_0000),
                                              DataType.Mapping(name: "J_SELECT", value: 0b0100_0000),
                                              DataType.Mapping(name: "J_START", value: 0b1000_0000),
                                            ]))
    configuration.dataTypes.append(DataType(name: "JOYPAD",
                                            representation: DataType.Representation.binary,
                                            interpretation: DataType.Interpretation.bitmask,
                                            mappings: [
                                              DataType.Mapping(name: "JOYPAD_DIRECTIONS", value: 0b0001_0000),
                                              DataType.Mapping(name: "JOYPAD_BUTTONS", value: 0b0010_0000),
                                            ]))

    configuration.globals.append(contentsOf: [
      Global(name: "HeaderIsColorGB", address: 0x0143, dataType: "HW_COLORGAMEBOY"),
      Global(name: "HeaderSGBFlag", address: 0x0146, dataType: "HW_SUPERGAMEBOY"),
      Global(name: "HeaderCartridgeType", address: 0x0147, dataType: "HW_CARTRIDGETYPE"),
      Global(name: "HeaderROMSize", address: 0x0148, dataType: "HW_ROMSIZE"),
      Global(name: "HeaderRAMSize", address: 0x0149, dataType: "HW_RAMSIZE"),
      Global(name: "HeaderDestinationCode", address: 0x014A, dataType: "HW_DESTINATIONCODE"),
      Global(name: "gbVRAM", address: 0x8000, dataType: "hex"),
      Global(name: "gbBGCHARDAT", address: 0x8800, dataType: "hex"),
      Global(name: "gbBGDAT0", address: 0x9800, dataType: "hex"),
      Global(name: "gbBGDAT1", address: 0x9c00, dataType: "hex"),
      Global(name: "gbCARTRAM", address: 0xa000, dataType: "hex"),
      Global(name: "gbRAM", address: 0xc000, dataType: "hex"),
      Global(name: "gbOAMRAM", address: 0xfe00, dataType: "hex"),
      Global(name: "gbP1", address: 0xff00, dataType: "JOYPAD"),
      Global(name: "gbSB", address: 0xff01, dataType: "hex"),
      Global(name: "gbSC", address: 0xff02, dataType: "hex"),
      Global(name: "gbDIV", address: 0xff04, dataType: "hex"),
      Global(name: "gbTIMA", address: 0xff05, dataType: "hex"),
      Global(name: "gbTMA", address: 0xff06, dataType: "hex"),
      Global(name: "gbTAC", address: 0xff07, dataType: "hex"),
      Global(name: "gbIF", address: 0xff0f, dataType: "hex"),
      Global(name: "gbAUD1SWEEP", address: 0xff10, dataType: "hex"),
      Global(name: "gbAUD1LEN", address: 0xff11, dataType: "hex"),
      Global(name: "gbAUD1ENV", address: 0xff12, dataType: "hex"),
      Global(name: "gbAUD1LOW", address: 0xff13, dataType: "hex"),
      Global(name: "gbAUD1HIGH", address: 0xff14, dataType: "hex"),
      Global(name: "gbAUD2LEN", address: 0xff16, dataType: "hex"),
      Global(name: "gbAUD2ENV", address: 0xff17, dataType: "hex"),
      Global(name: "gbAUD2LOW", address: 0xff18, dataType: "hex"),
      Global(name: "gbAUD2HIGH", address: 0xff19, dataType: "hex"),
      Global(name: "gbAUD3ENA", address: 0xff1a, dataType: "hex"),
      Global(name: "gbAUD3LEN", address: 0xff1b, dataType: "hex"),
      Global(name: "gbAUD3LEVEL", address: 0xff1c, dataType: "hex"),
      Global(name: "gbAUD3LOW", address: 0xff1d, dataType: "hex"),
      Global(name: "gbAUD3HIGH", address: 0xff1e, dataType: "hex"),
      Global(name: "gbAUD4LEN", address: 0xff20, dataType: "hex"),
      Global(name: "gbAUD4ENV", address: 0xff21, dataType: "hex"),
      Global(name: "gbAUD4POLY", address: 0xff22, dataType: "hex"),
      Global(name: "gbAUD4CONSEC", address: 0xff23, dataType: "hex"),
      Global(name: "gbAUDVOL", address: 0xff24, dataType: "hex"),
      Global(name: "gbAUDTERM", address: 0xff25, dataType: "hex"),
      Global(name: "gbAUDENA", address: 0xff26, dataType: "hex"),
      Global(name: "gbAUD3WAVERAM", address: 0xff30, dataType: "hex"),
      Global(name: "gbLCDC", address: 0xff40, dataType: "LCDCF"),
      Global(name: "gbSTAT", address: 0xff41, dataType: "STATF"),
      Global(name: "gbSCY", address: 0xff42, dataType: "decimal"),
      Global(name: "gbSCX", address: 0xff43, dataType: "decimal"),
      Global(name: "gbLY", address: 0xff44, dataType: "decimal"),
      Global(name: "gbLYC", address: 0xff45, dataType: "decimal"),
      Global(name: "gbDMA", address: 0xff46, dataType: "hex"),
      Global(name: "gbBGP", address: 0xff47, dataType: "hex"),
      Global(name: "gbOBP0", address: 0xff48, dataType: "hex"),
      Global(name: "gbOBP1", address: 0xff49, dataType: "hex"),
      Global(name: "gbWY", address: 0xff4a, dataType: "hex"),
      Global(name: "gbWX", address: 0xff4b, dataType: "hex"),
      Global(name: "gbKEY1", address: 0xff4d, dataType: "hex"),
      Global(name: "gbVBK", address: 0xff4f, dataType: "hex"),
      Global(name: "gbHDMA1", address: 0xff51, dataType: "hex"),
      Global(name: "gbHDMA2", address: 0xff52, dataType: "hex"),
      Global(name: "gbHDMA3", address: 0xff53, dataType: "hex"),
      Global(name: "gbHDMA4", address: 0xff54, dataType: "hex"),
      Global(name: "gbHDMA5", address: 0xff55, dataType: "hex"),
      Global(name: "gbRP", address: 0xff56, dataType: "hex"),
      Global(name: "gbBCPS", address: 0xff68, dataType: "hex"),
      Global(name: "gbBCPD", address: 0xff69, dataType: "hex"),
      Global(name: "gbOCPS", address: 0xff6a, dataType: "hex"),
      Global(name: "gbOCPD", address: 0xff6b, dataType: "hex"),
      Global(name: "gbSVBK", address: 0xff70, dataType: "hex"),
      Global(name: "gbPCM12", address: 0xff76, dataType: "hex"),
      Global(name: "gbPCM34", address: 0xff77, dataType: "hex"),
      Global(name: "gbIE", address: 0xffff, dataType: "HW_IE"),
    ])

    // TODO: Handle data and text definitions.
//    setData(at: 0x0104..<0x0134, in: 0x00)
//    setText(at: 0x0134..<0x0143, in: 0x00)
//    setData(at: 0x0144..<0x0146, in: 0x00)
//    setData(at: 0x0147, in: 0x00)
//    setData(at: 0x014B, in: 0x00)
//    setData(at: 0x014C, in: 0x00)
//    setData(at: 0x014D, in: 0x00)
//    setData(at: 0x014E..<0x0150, in: 0x00)
  }

  private var documentFileWrapper: FileWrapper?

  override func makeWindowControllers() {
    let contentViewController = ProjectViewController(document: self)
    self.contentViewController = contentViewController
    let window = NSWindow(contentViewController: contentViewController)
    window.setContentSize(NSSize(width: 1280, height: 768))
    window.toolbarStyle = .unifiedCompact
    window.tabbingMode = .disallowed
    let wc = NSWindowController(window: window)
    wc.window?.styleMask.insert(.fullSizeContentView)
    wc.contentViewController = contentViewController
    addWindowController(wc)
    window.setFrameAutosaveName("windowFrame")

    let toolbar = NSToolbar()
    toolbar.delegate = self
    wc.window?.toolbar = toolbar

    window.makeKeyAndOrderFront(nil)
  }
}

// MARK: - Toolbar

private extension NSToolbarItem.Identifier {
  static let leadingSidebarTrackingSeparator = NSToolbarItem.Identifier(rawValue: "leadingSidebarTrackingSeperator")
  static let trailingSidebarTrackingSeparator = NSToolbarItem.Identifier(rawValue: "trailingSidebarTrackingSeperator")
  static let disassemble = NSToolbarItem.Identifier(rawValue: "disassemble")
}

extension ProjectDocument: NSToolbarDelegate {
  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      .leadingSidebarTrackingSeparator,
      .disassemble,
      .trailingSidebarTrackingSeparator,
    ]
  }

  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      .leadingSidebarTrackingSeparator,
      .trailingSidebarTrackingSeparator,
      .disassemble,
    ]
  }

  func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    switch itemIdentifier {
    case .leadingSidebarTrackingSeparator:
      return NSTrackingSeparatorToolbarItem(
        identifier: itemIdentifier,
        splitView: contentViewController!.splitViewController.splitView,
        dividerIndex: 0
      )
    case .trailingSidebarTrackingSeparator:
      return NSTrackingSeparatorToolbarItem(
        identifier: itemIdentifier,
        splitView: contentViewController!.splitViewController.splitView,
        dividerIndex: 1
      )
    case .disassemble:
      let item = NSToolbarItem(itemIdentifier: itemIdentifier)
      item.target = self
      item.action = #selector(disassemble(_:))
      item.image = NSImage(systemSymbolName: "chevron.left.slash.chevron.right", accessibilityDescription: "Disassemble the rom")
      return item
    default:
      return NSToolbarItem(itemIdentifier: itemIdentifier)
    }
  }
}

extension RGBDS.Statement {
  func attributedString(attributes: [NSAttributedString.Key : Any],
                        opcodeAttributes: [NSAttributedString.Key : Any],
                        operandAttributes: [NSAttributedString.Key : Any],
                        regionLookup: [String: Region],
                        scope: String?) -> NSAttributedString {
    let string = NSMutableAttributedString()
    string.beginEditing()
    string.append(NSAttributedString(string: formattedOpcode, attributes: opcodeAttributes))
    if !operands.isEmpty {
      string.append(NSAttributedString(string: " ", attributes: attributes))

      let separator = ", "
      var accumulatedLength = 0
      let operandStrings: [(String, (Int, String)?)] = operands.map { operand in
        let label: String
        if let scope = scope, operand.starts(with: ".") {
          label = scope + operand
        } else {
          label = operand
        }

        let lengthSoFar = accumulatedLength
        accumulatedLength += operand.count + separator.count
        if regionLookup[label] != nil {
          return (operand, (lengthSoFar, "gbdis://jumpto/\(label)"))
        } else {
          return (operand, nil)
        }
      }
      let operandString = NSMutableAttributedString(string: operandStrings.map { $0.0 }.joined(separator: separator),
                                                    attributes: operandAttributes)
      operandStrings.filter { $0.1 != nil }.forEach {
        operandString.addAttribute(.link, value: $0.1!.1, range: NSRange(($0.1!.0..<$0.1!.0 + $0.0.count)))
      }
      string.append(operandString)
    }
    string.endEditing()
    return string
  }
}

// MARK: - Document modifications

extension ProjectDocument {
  @objc func disassemble(_ sender: Any?) {
    guard let romData = romData else {
      return
    }
    isDisassembling = true
    self.contentViewController?.startProgressIndicator()

    DispatchQueue.global(qos: .userInitiated).async {
      let disassembly = LR35902.Disassembly(rom: romData)

      for dataType in self.configuration.dataTypes {
        let mappingDict = dataType.mappings.reduce(into: [:]) { accumulator, mapping in
          accumulator[mapping.value] = mapping.name
        }
        let representation: LR35902.Disassembly.Datatype.Representation
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
          disassembly.createDatatype(named: dataType.name, representation: representation)
        case DataType.Interpretation.bitmask:
          disassembly.createDatatype(named: dataType.name, bitmask: mappingDict, representation: representation)
        case DataType.Interpretation.enumerated:
          disassembly.createDatatype(named: dataType.name, enumeration: mappingDict, representation: representation)
        default:
          preconditionFailure()
        }
      }

      for global in self.configuration.globals {
        disassembly.createGlobal(at: global.address, named: global.name, dataType: global.dataType)
      }

      // Disassemble everything first
      for region in self.configuration.regions {
        switch region.regionType {
        case Region.Kind.region:
          disassembly.setLabel(at: region.address, in: region.bank, named: region.name)
          if region.length > 0 {
            disassembly.disassemble(range: region.address..<(region.address + region.length), inBank: region.bank)
          }
        case Region.Kind.function:
          disassembly.defineFunction(startingAt: region.address, in: region.bank, named: region.name)
        default:
          break
        }
      }

      // And then set any explicit regions
      for region in self.configuration.regions {
        switch region.regionType {
        case Region.Kind.label:
          disassembly.setLabel(at: region.address, in: region.bank, named: region.name)
        case Region.Kind.string:
          disassembly.setLabel(at: region.address, in: region.bank, named: region.name)
          disassembly.setText(at: region.address..<(region.address + region.length), in: region.bank, lineLength: nil)
        case Region.Kind.image1bpp:
          disassembly.setLabel(at: region.address, in: region.bank, named: region.name)
          disassembly.setData(at: region.address..<(region.address + region.length), in: region.bank, format: .image1bpp)
        case Region.Kind.image2bpp:
          disassembly.setLabel(at: region.address, in: region.bank, named: region.name)
          disassembly.setData(at: region.address..<(region.address + region.length), in: region.bank, format: .image2bpp)
        case Region.Kind.data:
          disassembly.setLabel(at: region.address, in: region.bank, named: region.name)
          disassembly.setData(at: region.address..<(region.address + region.length), in: region.bank)
        default:
          break
        }
      }

      for macro in self.configuration.macros {
        disassembly.defineMacro(named: macro.name, template: macro.source)
      }

      //            disassembly.disassembleAsGameboyCartridge()
      let (disassembledSource, statistics) = try! disassembly.generateSource()

      let bankMap: [String: LR35902.Bank] = disassembledSource.sources.reduce(into: [:], { accumulator, element in
        if case .bank(let number, _, _) = element.value {
          accumulator[element.key] = number
        }
      })
      let bankLines: [LR35902.Bank: [LR35902.Disassembly.Line]] = disassembledSource.sources.compactMapValues {
        switch $0 {
        case .bank(_, _, let lines):
          return lines
        default:
          return nil
        }
      }.reduce(into: [:]) { accumulator, entry in
        accumulator[bankMap[entry.0]!] = entry.1
      }

      var regionLookup: [String: Region] = [:]
      let regions: [Region] = bankLines.reduce(into: []) { accumulator, element in
        let bank = element.key
        accumulator.append(contentsOf: element.value.reduce(into: []) { accumulator, line in
          switch line.semantic {
          case let .label(name): fallthrough
          case let .transferOfControl(_, name):
            let region = Region(
              regionType: Region.Kind.label,
              name: name,
              bank: bank,
              address: line.address!,
              length: 0
            )
            accumulator.append(region)
            regionLookup[name] = region
            break
          default:
            break
          }
        })
      }

      let commentColor = NSColor.systemGreen
      let labelColor = NSColor.systemOrange
      let baseAttributes: [NSAttributedString.Key : Any] = [
        .foregroundColor: NSColor.textColor,
        .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
      ]
      let opcodeAttributes: [NSAttributedString.Key : Any] = [
        .foregroundColor: NSColor.systemGreen,
        .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
      ]
      let macroNameAttributes: [NSAttributedString.Key : Any] = [
        .foregroundColor: NSColor.systemBrown,
        .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
      ]
      let operandAttributes: [NSAttributedString.Key : Any] = baseAttributes

      let bankTextStorage: [LR35902.Bank: NSAttributedString] = disassembledSource.sources.compactMapValues {
        switch $0 {
        case .bank(_, _, let lines):
          return lines.reduce(into: NSMutableAttributedString()) { accumulator, line in
            switch line.semantic {
            case .newline: fallthrough
            case .empty:
              break // Do nothing.
            case .macroComment: fallthrough
            case .preComment:
              accumulator.append(NSAttributedString(string: line.asString(detailedComments: false), attributes: [
                .foregroundColor: commentColor,
                .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
              ]))
            case .label: fallthrough
            case .transferOfControl:
              accumulator.append(NSAttributedString(string: line.asString(detailedComments: false), attributes: [
                .foregroundColor: labelColor,
                .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
              ]))
            case .section: fallthrough
            case .macroDefinition: fallthrough
            case .macroTerminator: fallthrough
            case .jumpTable:
              accumulator.append(NSAttributedString(string: line.asString(detailedComments: false),
                                                    attributes: baseAttributes))
            case let .text(assembly): fallthrough
            case let .data(assembly): fallthrough
            case let .unknown(assembly): fallthrough
            case let .global(assembly, _, _): fallthrough
            case let .image1bpp(assembly): fallthrough
            case let .image2bpp(assembly): fallthrough
            case let .macroInstruction(_, assembly): fallthrough
            case let .instruction(_, assembly):
              accumulator.append(NSAttributedString(string: "    ", attributes: baseAttributes))
              accumulator.append(assembly.attributedString(attributes: baseAttributes,
                                                           opcodeAttributes: opcodeAttributes,
                                                           operandAttributes: operandAttributes,
                                                           regionLookup: regionLookup,
                                                           scope: line.scope))
            case let .macro(assembly):
              accumulator.append(NSAttributedString(string: "    ", attributes: baseAttributes))
              accumulator.append(assembly.attributedString(attributes: baseAttributes,
                                                           opcodeAttributes: macroNameAttributes,
                                                           operandAttributes: operandAttributes,
                                                           regionLookup: regionLookup,
                                                           scope: line.scope))

            case let .imagePlaceholder(format):
              switch format {
              case .oneBitPerPixel:
                let data = line.data!
                let scale: CGFloat = 4
                let imageSize = NSSize(width: 48 * scale + 4 * scale, height: 8 * scale + 4 * scale)
                let image = NSImage(size: imageSize)
                image.lockFocusFlipped(true)
                NSColor.textColor.set()

                var column: CGFloat = 0
                var row: CGFloat = 0
                let pixel = NSRect(x: 2 * scale, y: 2 * scale, width: scale, height: scale)
                var alternator = false
                for byte in data {
                  if (byte & 0x80) != 0 {
                    pixel.offsetBy(dx: column, dy: row).fill()
                  }
                  if (byte & 0x40) != 0 {
                    pixel.offsetBy(dx: column + 1 * scale, dy: row).fill()
                  }
                  if (byte & 0x20) != 0 {
                    pixel.offsetBy(dx: column + 2 * scale, dy: row).fill()
                  }
                  if (byte & 0x10) != 0 {
                    pixel.offsetBy(dx: column + 3 * scale, dy: row).fill()
                  }
                  if (byte & 0x08) != 0 {
                    pixel.offsetBy(dx: column, dy: row + 1 * scale).fill()
                  }
                  if (byte & 0x04) != 0 {
                    pixel.offsetBy(dx: column + 1 * scale, dy: row + 1 * scale).fill()
                  }
                  if (byte & 0x02) != 0 {
                    pixel.offsetBy(dx: column + 2 * scale, dy: row + 1 * scale).fill()
                  }
                  if (byte & 0x01) != 0 {
                    pixel.offsetBy(dx: column + 3 * scale, dy: row + 1 * scale).fill()
                  }
                  if alternator {
                    column += 4 * scale
                    row -= 2 * scale
                  } else {
                    row += 2 * scale
                  }
                  alternator = !alternator
                  if column >= (imageSize.width - 4 * scale) {
                    column = 0
                    row += 4 * scale
                  }
                }

                image.unlockFocus()

                let textAttachment = NSTextAttachment()
                textAttachment.image = image
                accumulator.append(NSAttributedString(attachment: textAttachment))
              case .twoBitsPerPixel:
                let data = line.data!
                let scale: CGFloat = 8
                let tiles = data.count / 16
                let totalColumns = min(8, (tiles + 1) / 2)
                let totalRows = (tiles - 1) / 16 * 2 + ((tiles - 1) % 16 >= 1 ? 2 : 1)
                let imageSize = NSSize(width: CGFloat(totalColumns) * 8 * scale + 4 * scale,
                                       height: CGFloat(totalRows) * 8 * scale + 4 * scale)
                let image = NSImage(size: imageSize)
                image.lockFocusFlipped(true)
                NSColor.textColor.set()

                let colorForBytePair: (UInt8, UInt8, UInt8) -> UInt8 = { highByte, lowByte, bit in
                  let mask = UInt8(0x01) << bit
                  return (((highByte & mask) >> bit) << 1) | ((lowByte & mask) >> bit)
                }

                let colors: [NSColor] = [
                  .black,
                  .darkGray,
                  .lightGray,
                  .white,
                ]

                var tileColumn = 0
                var tileRow = 0
                var pixelRow = 0
                let pixel = NSRect(x: 2 * scale, y: 2 * scale, width: scale, height: scale)
                for bytePairs in [UInt8](data).chunked(into: 2) {
                  let lowByte = bytePairs.first!
                  let highByte = bytePairs.last!

                  for i: UInt8 in 0..<8 {
                    colors[Int(colorForBytePair(highByte, lowByte, 7 - i))].set()
                    pixel.offsetBy(dx: CGFloat(tileColumn) * 8 * scale + CGFloat(i) * scale,
                                   dy: CGFloat(tileRow) * 8 * scale + CGFloat(pixelRow) * scale).fill()
                  }
                  pixelRow += 1
                  if pixelRow >= 16 {
                    tileColumn += 1
                    pixelRow = 0

                    if tileColumn >= 8 {
                      tileColumn = 0
                      tileRow += 2
                    }
                  }
                }

                image.unlockFocus()

                let textAttachment = NSTextAttachment()
                textAttachment.image = image
                accumulator.append(NSAttributedString(attachment: textAttachment))
                break
              }
              break
            }
            accumulator.append(NSAttributedString(string: "\n"))
          }
        default:
          return nil
        }
      }.reduce(into: [:]) { accumulator, entry in
        accumulator[bankMap[entry.0]!] = entry.1
      }
      let disassemblyFiles: [String: Data] = disassembledSource.sources.mapValues {
        switch $0 {
        case .bank(_, let content, _): fallthrough
        case .charmap(content: let content): fallthrough
        case .datatypes(content: let content): fallthrough
        case .game(content: let content): fallthrough
        case .macros(content: let content): fallthrough
        case .makefile(content: let content): fallthrough
        case .variables(content: let content):
          return content.data(using: .utf8)!
        }
      }

      DispatchQueue.main.async {
        self.metadata?.numberOfBanks = disassembly.cpu.cartridge.numberOfBanks
        self.metadata?.bankMap = bankMap
        self.disassemblyResults = DisassemblyResults(
          files: disassemblyFiles,
          bankLines: bankLines,
          bankTextStorage: bankTextStorage,
          regions: regions,
          regionLookup: regionLookup,
          statistics: statistics
        )

        self.isDisassembling = false
        NotificationCenter.default.post(name: .disassembled, object: self)

        self.contentViewController?.stopProgressIndicator()
      }
    }
  }

  @objc func loadRom(_ sender: Any?) {
    let openPanel = NSOpenPanel()
    openPanel.allowedFileTypes = ["gb"]
    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = false
    if let window = contentViewController?.view.window {
      openPanel.beginSheetModal(for: window) { response in
        if response == .OK, let url = openPanel.url {
          let data = try! Data(contentsOf: url)
          self.romData = data

          self.metadata = ProjectMetadata(
            romUrl: url,
            numberOfBanks: 0,
            bankMap: [:]
          )
          self.disassemble(nil)
        }
      }
    }
  }
}

// MARK: - Document loading and saving

extension ProjectDocument {
  override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
    guard let fileWrappers = fileWrapper.fileWrappers else {
      preconditionFailure()
    }

    if let metadataFileWrapper = fileWrappers[Filenames.metadata],
       let encodedMetadata = metadataFileWrapper.regularFileContents {
      let decoder = PropertyListDecoder()
      let metadata = try decoder.decode(ProjectMetadata.self, from: encodedMetadata)
      self.metadata = metadata
    }

    if let fileWrapper = fileWrappers[Filenames.configuration],
       let regularFileContents = fileWrapper.regularFileContents {
      let decoder = PropertyListDecoder()
      self.configuration = try decoder.decode(ProjectConfiguration.self, from: regularFileContents)
    }

    if let fileWrapper = fileWrappers[Filenames.rom],
       let data = fileWrapper.regularFileContents {
      self.romData = data
    }

    if let fileWrapper = fileWrappers[Filenames.disassembly] {
      if let files = fileWrapper.fileWrappers?.mapValues({ $0.regularFileContents! }) {
        self.disassemblyResults = DisassemblyResults(files: files, bankLines: nil)
      }
    }

    self.disassemble(nil)
  }

  override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
    if documentFileWrapper == nil {
      documentFileWrapper = FileWrapper(directoryWithFileWrappers: [:])
    }
    guard let documentFileWrapper = documentFileWrapper else {
      preconditionFailure()
    }
    guard let fileWrappers = documentFileWrapper.fileWrappers else {
      preconditionFailure()
    }

    if let metadataFileWrapper = fileWrappers[Filenames.metadata] {
      documentFileWrapper.removeFileWrapper(metadataFileWrapper)
    }
    let encoder = PropertyListEncoder()
    let encodedMetadata = try encoder.encode(metadata)
    let metadataFileWrapper = FileWrapper(regularFileWithContents: encodedMetadata)
    metadataFileWrapper.preferredFilename = Filenames.metadata
    documentFileWrapper.addFileWrapper(metadataFileWrapper)

    if let fileWrapper = fileWrappers[Filenames.configuration] {
      documentFileWrapper.removeFileWrapper(fileWrapper)
    }
    let encodedConfiguration = try encoder.encode(configuration)
    let configurationFileWrapper = FileWrapper(regularFileWithContents: encodedConfiguration)
    configurationFileWrapper.preferredFilename = Filenames.configuration
    documentFileWrapper.addFileWrapper(configurationFileWrapper)

    if let romData = romData {
      if let fileWrapper = fileWrappers[Filenames.rom] {
        documentFileWrapper.removeFileWrapper(fileWrapper)
      }
      let fileWrapper = FileWrapper(regularFileWithContents: romData)
      fileWrapper.preferredFilename = Filenames.rom
      documentFileWrapper.addFileWrapper(fileWrapper)
    }

    // TODO: Wait until the assembly has finished?
    if let disassemblyResults = disassemblyResults {
      let wrappers = disassemblyResults.files.mapValues { content in
        FileWrapper(regularFileWithContents: content)
      }
      if let fileWrapper = fileWrappers[Filenames.disassembly] {
        documentFileWrapper.removeFileWrapper(fileWrapper)
      }
      let fileWrapper = FileWrapper(directoryWithFileWrappers: wrappers)
      fileWrapper.preferredFilename = Filenames.disassembly
      documentFileWrapper.addFileWrapper(fileWrapper)
    }
    return documentFileWrapper
  }
}
