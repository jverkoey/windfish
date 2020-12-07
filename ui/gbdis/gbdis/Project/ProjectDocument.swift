//
//  Document.swift
//  gbdis
//
//  Created by Jeff Verkoeyen on 11/30/20.
//

import Cocoa

import LR35902

final class Region: NSObject, NSCopying, Codable {
  struct Kind {
    static let region = "Region"
    static let label = "Label"
    static let function = "Function"
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

  func copy(with zone: NSZone? = nil) -> Any {
    return Region(regionType: regionType, name: name, bank: bank, address: address, length: length)
  }
}

class ProjectConfiguration: NSObject, Codable {
  @objc dynamic var regions: [Region] = []
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
  var disassemblyFiles: [String: Data]?
  var bankLines: [LR35902.Bank: [LR35902.Disassembly.Line]]?

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

    configuration.regions.append(Region(regionType: Region.Kind.region, name: "VBlankInterrupt", bank: 0, address: 0x0040, length: 8))
    configuration.regions.append(Region(regionType: Region.Kind.region, name: "LCDCInterrupt", bank: 0, address: 0x0048, length: 8))
    configuration.regions.append(Region(regionType: Region.Kind.region, name: "TimerOverflowInterrupt", bank: 0, address: 0x0050, length: 8))
    configuration.regions.append(Region(regionType: Region.Kind.region, name: "SerialTransferCompleteInterrupt", bank: 0, address: 0x0058, length: 8))
    configuration.regions.append(Region(regionType: Region.Kind.region, name: "JoypadTransitionInterrupt", bank: 0, address: 0x0060, length: 8))
    configuration.regions.append(Region(regionType: Region.Kind.region, name: "Boot", bank: 0, address: 0x0100, length: 4))
  }

  private var documentFileWrapper: FileWrapper?

  override func makeWindowControllers() {
    let contentViewController = ProjectViewController(document: self)
    self.contentViewController = contentViewController
    let window = NSWindow(contentViewController: contentViewController)
    window.setContentSize(NSSize(width: 800, height: 600))
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

      for region in self.configuration.regions {
        switch region.regionType {
        case Region.Kind.region:
          disassembly.setLabel(at: region.address, in: region.bank, named: region.name)
          if region.length > 0 {
            disassembly.disassemble(range: region.address..<(region.address + region.length), inBank: region.bank)
          }
        case Region.Kind.label:
          disassembly.setLabel(at: region.address, in: region.bank, named: region.name)
        case Region.Kind.function:
          disassembly.defineFunction(startingAt: region.address, in: region.bank, named: region.name)
        default:
          preconditionFailure()
        }
      }

      //            disassembly.disassembleAsGameboyCartridge()
      let disassembledSource = try! disassembly.generateSource()

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
        self.disassemblyFiles = disassemblyFiles
        self.metadata?.numberOfBanks = disassembly.cpu.numberOfBanks
        self.metadata?.bankMap = bankMap
        self.bankLines = bankLines

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
      self.disassemblyFiles = fileWrapper.fileWrappers?.mapValues {
        $0.regularFileContents!
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
    if let disassemblyFiles = disassemblyFiles {
      let wrappers = disassemblyFiles.mapValues { content in
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
