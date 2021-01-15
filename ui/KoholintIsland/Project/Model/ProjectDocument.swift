import AppKit
import Foundation
import Cocoa

import Windfish

@objc(ProjectDocument)
class ProjectDocument: NSDocument {
  weak var contentViewController: ProjectViewController?

  var sameboy: Emulator
  var sameboyView = GBView()
  var sameboyDebuggerSemaphore = DispatchSemaphore(value: 0)
  var nextDebuggerCommand: String? = nil

  var isDisassembling = false
  var romData: Data? {
    didSet {
      if let romData = romData {
        gameboy.cartridge = .init(data: romData)
        gameboy.cpu.pc = 0x100  // Assume the boot sequence has concluded.

        sameboyView.screenSizeChanged()

        let screenSize = sameboy.screenSize
        if let window = self.lcdWindowController.window {
          self.lcdWindowController.window?.contentMinSize = screenSize
          if window.contentView!.bounds.size.width < screenSize.width ||
              window.contentView!.bounds.size.width < screenSize.height {
            window.zoom(nil)
          }
        }

        romData.withUnsafeBytes { buffer in
          sameboy.loadROM(fromBuffer: buffer, size: romData.count)
        }

        sameboy.start()
        sameboy.debuggerBreak()

      } else {
        preconditionFailure()
      }
    }
  }
  @objc dynamic var disassemblyResults: DisassemblyResults?
  var metadata: ProjectMetadata?
  var configuration = ProjectConfiguration()
  var gameboy = Gameboy()

  var emulating = false
  var lastVblankCounter: Int? = nil
  var lastVBlankImage: NSImage? = nil
  var lastTileDataCounter: Int? = nil
  var lastTileDataImage: NSImage? = nil
  var vblankHistory: [NSImage] = []
  var emulationObservers: [EmulationObservers] = []
  var breakpointPredicate: NSPredicate?

  deinit {
    lcdWindowController.close()
  }

  override init() {
    self.sameboy = Emulator(model: GB_MODEL_DMG_B)

    super.init()

    self.sameboy.setDebuggerEnabled(true)
    self.sameboy.delegate = self

    self.sameboyView.emulator = self.sameboy

    applyDefaults()
  }

  var address: LR35902.Address {
    return sameboy.gb.pointee.pc
  }
  var bank: Gameboy.Cartridge.Bank {
    return Gameboy.Cartridge.Bank(truncatingIfNeeded: sameboy.gb.pointee.mbc_rom_bank)
  }

  private var documentFileWrapper: FileWrapper?

  override func makeWindowControllers() {
    let contentViewController = ProjectViewController(document: self)
    self.contentViewController = contentViewController
    let window = NSWindow(contentViewController: contentViewController)
    window.setContentSize(NSSize(width: 1280, height: 768))
    window.toolbarStyle = .unifiedCompact
    window.tabbingMode = .disallowed
    window.setFrameOrigin(.init(x: 0, y: NSScreen.main!.frame.maxY - window.frame.height))
    let wc = NSWindowController(window: window)
    wc.window?.styleMask.insert(.fullSizeContentView)
    wc.contentViewController = contentViewController
    addWindowController(wc)

    let toolbar = NSToolbar()
    toolbar.delegate = self
    wc.window?.toolbar = toolbar

    addWindowController(lcdWindowController)
    addWindowController(vramWindowController)
    addWindowController(ppuWindowController)

    toggleLCD(self)
    toggleVRAM(self)
    togglePPU(self)

    window.makeKeyAndOrderFront(nil)
  }

  @IBOutlet var vramTabView: NSTabView?
  @IBOutlet var vramWindow: NSPanel?
  @IBOutlet var paletteTableView: NSTableView?
  @IBOutlet var spritesTableView: NSTableView?

  @IBOutlet var gridButton: NSButton?

  @IBOutlet var tilesetPaletteButton: NSPopUpButton?
  @IBOutlet var tilesetImageView: GBImageView?

  @IBOutlet var tilemapImageView: GBImageView?
  @IBOutlet var tilemapPaletteButton: NSPopUpButton?
  @IBOutlet var tilemapMapButton: NSPopUpButton?
  @IBOutlet var tilemapSetButton: NSPopUpButton?
  var oamInfo = ContiguousArray<GB_oam_info_t>(repeating: GB_oam_info_t(), count: 40)
  var oamUpdating = false
  var oamCount: UInt8 = 0
  var oamHeight: UInt8 = 0

  lazy var lcdWindowController: NSWindowController = {
    let contentViewController = LCDViewController()
    let window: NSPanel = NSPanel(contentViewController: contentViewController)
    window.isFloatingPanel = true
    window.styleMask.insert(.hudWindow)
    window.subtitle = "LCD"
    window.setContentSize(NSSize(width: PPU.screenSize.width * 2, height: PPU.screenSize.height * 2))
    window.contentMinSize = NSSize(width: PPU.screenSize.width, height: PPU.screenSize.height)
    window.setFrameOrigin(.init(x: NSScreen.main!.frame.maxX - window.frame.width,
                                y: NSScreen.main!.frame.maxY - window.frame.height))
    let wc: NSWindowController = NSWindowController(window: window)
    wc.contentViewController = contentViewController
    return wc
  }()

  lazy var vramWindowController: NSWindowController = {
    Bundle.main.loadNibNamed("VRAMViewer", owner: self, topLevelObjects: nil)
    guard let vramWindow = vramWindow else {
      fatalError()
    }
    return NSWindowController(window: vramWindow)
  }()

  lazy var ppuWindowController: NSWindowController = {
    let contentViewController = PPUViewController()
    let window = NSPanel(contentViewController: contentViewController)
    window.isFloatingPanel = true
    window.styleMask.insert(.hudWindow)
    window.subtitle = "PPU"
    window.contentMinSize = NSSize(width: 400, height: 400)
    window.setFrameOrigin(.init(x: NSScreen.main!.frame.maxX - window.frame.width,
                                y: NSScreen.main!.frame.maxY - window.frame.height - lcdWindowController.window!.frame.height))
    window.setContentSize(window.contentMinSize)
    let wc = NSWindowController(window: window)
    wc.contentViewController = contentViewController
    return wc
  }()

  @objc func toggleLCD(_ sender: Any?) {
    lcdWindowController.showWindow(self)
    lcdWindowController.window?.orderFront(self)
  }

  @objc func toggleVRAM(_ sender: Any?) {
    vramWindowController.showWindow(self)
    vramWindowController.window?.orderFront(self)
    reloadVRAMData(nil)
  }

  @objc func togglePPU(_ sender: Any?) {
    ppuWindowController.showWindow(self)
    ppuWindowController.window?.orderFront(self)
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

private struct Filenames {
  static let metadata = "metadata.plist"
  static let rom = "rom.gb"
  static let disassembly = "disassembly"
  static let configuration = "configuration.plist"
}

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
