import AppKit
import Foundation
import Cocoa

import Windfish

final class Project: NSObject {

  override init() {
    self.sameboy = Emulator(model: GB_MODEL_DMG_B)

    super.init()

    self.sameboy.setDebuggerEnabled(true)
    self.sameboy.delegate = self

    self.sameboyView.emulator = self.sameboy

    applyDefaults()
  }

  var sameboy: Emulator
  var sameboyView = GBView()
  var sameboyDebuggerSemaphore = DispatchSemaphore(value: 0)
  var nextDebuggerCommand: String? = nil

  var consoleOutputLock = NSRecursiveLock()
  var pendingConsoleOutput = NSMutableAttributedString()

  var isDisassembling = false
  var romData: Data? {
    didSet {
      if let romData = romData {
        gameboy.cartridge = .init(data: romData)
        gameboy.cpu.pc = 0x100  // Assume the boot sequence has concluded.

        sameboyView.screenSizeChanged()

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

  // Observers are typically view controllers that will also hold a reference to the project, so we keep weak references
  // to all of the observers.
  var emulationObservers = NSHashTable<EmulationObservers>(options: [.weakMemory, .objectPersonality])
  var logObservers: [LogObserver] = []
  var breakpointPredicate: NSPredicate?

  var address: LR35902.Address {
    return sameboy.gb.pointee.pc
  }
  var bank: Gameboy.Cartridge.Bank {
    return Gameboy.Cartridge.Bank(truncatingIfNeeded: sameboy.gb.pointee.mbc_rom_bank)
  }

}

@objc(ProjectDocument)
final class ProjectDocument: NSDocument {
  var project = Project()
  weak var contentViewController: ProjectViewController?

  deinit {
    lcdWindowController.close()
  }

  private var documentFileWrapper: FileWrapper?

  override func makeWindowControllers() {
    let contentViewController = ProjectViewController(project: project)
    self.contentViewController = contentViewController
    let window = NSWindow(contentViewController: contentViewController)
    window.setContentSize(NSSize(width: 1160, height: NSScreen.main!.frame.height))
    window.setFrameOrigin(.init(x: 0, y: NSScreen.main!.frame.maxY - window.frame.height))
    window.toolbarStyle = .unifiedCompact
    window.tabbingMode = .disallowed
    window.isRestorable = true
    let wc = NSWindowController(window: window)
    wc.window?.styleMask.insert(.fullSizeContentView)
    wc.contentViewController = contentViewController
    addWindowController(wc)

    let toolbar = NSToolbar()
    toolbar.delegate = self
    wc.window?.toolbar = toolbar

    addWindowController(lcdWindowController)
    addWindowController(vramWindowController)

    toggleLCD(self)
    toggleVRAM(self)

    window.makeKeyAndOrderFront(nil)
  }

  lazy var lcdWindowController: NSWindowController = {
    let contentViewController = LCDViewController(sameboyView: project.sameboyView)
    let window: NSPanel = NSPanel(contentViewController: contentViewController)
    window.isFloatingPanel = true
    window.styleMask.insert(.hudWindow)
    window.subtitle = "LCD"
    window.isRestorable = true
    window.setContentSize(NSSize(width: PPU.screenSize.width * 2, height: PPU.screenSize.height * 2))
    window.contentMinSize = NSSize(width: PPU.screenSize.width, height: PPU.screenSize.height)
    window.setFrameOrigin(.init(x: NSScreen.main!.frame.maxX - window.frame.width,
                                y: NSScreen.main!.frame.maxY - window.frame.height))
    let wc: NSWindowController = NSWindowController(window: window)
    wc.contentViewController = contentViewController
    return wc
  }()

  lazy var vramWindowController: NSWindowController = {
    let windowController = VRAMWindowController(windowNibName: "VRAMViewer")
    windowController.project = project
    windowController.window!.setFrameOrigin(.init(x: NSScreen.main!.frame.maxX - windowController.window!.frame.width,
                                                  y: NSScreen.main!.frame.maxY - windowController.window!.frame.height - CGFloat(PPU.screenSize.height * 2)))
    return windowController
  }()

  @objc func toggleLCD(_ sender: Any?) {
    lcdWindowController.showWindow(self)
    lcdWindowController.window?.orderFront(self)
  }

  @objc func toggleVRAM(_ sender: Any?) {
    vramWindowController.showWindow(self)
    vramWindowController.window?.orderFront(self)
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
        splitView: contentViewController!.threePaneSplitViewController.splitView,
        dividerIndex: 0
      )
    case .trailingSidebarTrackingSeparator:
      return NSTrackingSeparatorToolbarItem(
        identifier: itemIdentifier,
        splitView: contentViewController!.threePaneSplitViewController.splitView,
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
          self.project.romData = data

          self.project.metadata = ProjectMetadata(
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
      self.project.metadata = metadata
    }

    if let fileWrapper = fileWrappers[Filenames.configuration],
       let regularFileContents = fileWrapper.regularFileContents {
      let decoder = PropertyListDecoder()
      self.project.configuration = try decoder.decode(ProjectConfiguration.self, from: regularFileContents)
    }

    if let fileWrapper = fileWrappers[Filenames.rom],
       let data = fileWrapper.regularFileContents {
      self.project.romData = data
    }

    if let fileWrapper = fileWrappers[Filenames.disassembly] {
      if let files = fileWrapper.fileWrappers?.mapValues({ $0.regularFileContents! }) {
        self.project.disassemblyResults = DisassemblyResults(files: files, bankLines: nil)
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
    let encodedMetadata = try encoder.encode(project.metadata)
    let metadataFileWrapper = FileWrapper(regularFileWithContents: encodedMetadata)
    metadataFileWrapper.preferredFilename = Filenames.metadata
    documentFileWrapper.addFileWrapper(metadataFileWrapper)

    if let fileWrapper = fileWrappers[Filenames.configuration] {
      documentFileWrapper.removeFileWrapper(fileWrapper)
    }
    let encodedConfiguration = try encoder.encode(project.configuration)
    let configurationFileWrapper = FileWrapper(regularFileWithContents: encodedConfiguration)
    configurationFileWrapper.preferredFilename = Filenames.configuration
    documentFileWrapper.addFileWrapper(configurationFileWrapper)

    if let romData = project.romData {
      if let fileWrapper = fileWrappers[Filenames.rom] {
        documentFileWrapper.removeFileWrapper(fileWrapper)
      }
      let fileWrapper = FileWrapper(regularFileWithContents: romData)
      fileWrapper.preferredFilename = Filenames.rom
      documentFileWrapper.addFileWrapper(fileWrapper)
    }

    // TODO: Wait until the assembly has finished?
    if let disassemblyResults = project.disassemblyResults {
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
