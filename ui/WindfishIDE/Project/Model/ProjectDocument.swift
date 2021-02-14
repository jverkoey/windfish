import AppKit
import Foundation
import Cocoa

import LR35902
import RGBDS
import Tracing
import Windfish

final class Project: NSObject {

  override init() {
    self.sameboy = SameboyEmulator()

    super.init()

    self.sameboy.setDebuggerEnabled(true)
    self.sameboy.delegate = self

    self.sameboyView.bind(with: self.sameboy)

    applyDefaults()
  }

  var sameboy: SameboyEmulator
  var sameboyView = SameboyGBView()
  var sameboyDebuggerSemaphore = DispatchSemaphore(value: 0)
  var nextDebuggerCommand: String? = nil
  var debuggerLine: Int? = nil

  var consoleOutputLock = NSRecursiveLock()
  var pendingConsoleOutput = NSMutableAttributedString()

  var isDisassembling = false
  var romData: Data? {
    didSet {
      if let romData = romData {

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
    return sameboy.pc
  }
  var bank: Cartridge.Bank {
    return Cartridge.Bank(truncatingIfNeeded: sameboy.romBank)
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
    if #available(OSX 11.0, *) {
      window.toolbarStyle = .unifiedCompact
    }
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
    if #available(OSX 11.0, *) {
      window.subtitle = "LCD"
    } else {
      window.title = "LCD"
    }
    window.isRestorable = true
    window.setContentSize(NSSize(width: project.sameboy.screenSize.width * 2, height: project.sameboy.screenSize.height * 2))
    window.contentMinSize = NSSize(width: project.sameboy.screenSize.width, height: project.sameboy.screenSize.height)
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
                                                  y: NSScreen.main!.frame.maxY - windowController.window!.frame.height - CGFloat(project.sameboy.screenSize.height * 2)))
    return windowController
  }()

  @IBAction @objc func toggleLCD(_ sender: Any?) {
    lcdWindowController.showWindow(self)
    lcdWindowController.window?.orderFront(self)
  }

  @IBAction @objc func toggleVRAM(_ sender: Any?) {
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
    if #available(OSX 11.0, *) {
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
      default:
        break
      }
    }
    switch itemIdentifier {
    case .disassemble:
      let item = NSToolbarItem(itemIdentifier: itemIdentifier)
      item.target = self
      item.action = #selector(disassemble(_:))
      item.image = NSImage(systemSymbolNameOrImageName: "chevron.left.slash.chevron.right", accessibilityDescription: "Disassemble the rom")
      return item
    default:
      return NSToolbarItem(itemIdentifier: itemIdentifier)
    }
  }
}

// MARK: - Document modifications

extension ProjectDocument {
  @IBAction @objc func loadRom(_ sender: Any?) {
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

    // Configuration as human-editable files
    if let configuration = fileWrappers[Filenames.configurationDir] {
      if let scripts = configuration.fileWrappers?[Filenames.scriptsDir],
         let files = scripts.fileWrappers?.mapValues({ $0.regularFileContents! }) {
        self.project.configuration.scripts = files.compactMap({ (key: String, value: Data) -> Script? in
          guard let storage = Windfish.Project.loadScript(from: value, with: NSString(string: key).deletingPathExtension) else {
            return nil
          }
          return Script(storage: storage)
        })
      }
      if let macros = configuration.fileWrappers?[Filenames.macrosDir],
         let files = macros.fileWrappers?.mapValues({ $0.regularFileContents! }) {
        self.project.configuration.macros = files.compactMap({ (key: String, value: Data) -> Macro? in
          guard let storage = Windfish.Project.loadMacro(from: value, with: NSString(string: key).deletingPathExtension) else {
            return nil
          }
          return Macro(storage: storage)
        })
      }
      if let content: Data = configuration.fileWrappers?[Filenames.globals]?.regularFileContents {
        self.project.configuration.globals = Windfish.Project.loadGlobals(from: content).map { Global(storage: $0) }
      }
      if let content: Data = configuration.fileWrappers?[Filenames.dataTypes]?.regularFileContents {
        self.project.configuration.dataTypes = Windfish.Project.loadDataTypes(from: content).map { DataType(storage: $0) }
      }
      if let content: Data = configuration.fileWrappers?[Filenames.regions]?.regularFileContents {
        self.project.configuration.regions = Windfish.Project.loadRegions(from: content).map { Region(storage: $0) }
      }
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

    // Configuration as human-editable files
    if true {
      if let configuration = fileWrappers[Filenames.configurationDir] {
        documentFileWrapper.removeFileWrapper(configuration)
      }
      let configuration = FileWrapper(directoryWithFileWrappers: [
        Filenames.scriptsDir: FileWrapper(directoryWithFileWrappers: project.configuration.storage.scriptsAsData()
                                            .mapValues { FileWrapper(regularFileWithContents: $0) }),
        Filenames.macrosDir: FileWrapper(directoryWithFileWrappers: project.configuration.storage.macrosAsData()
                                            .mapValues { FileWrapper(regularFileWithContents: $0) }),
        Filenames.globals: FileWrapper(regularFileWithContents: project.configuration.storage.globalsAsData()),
        Filenames.dataTypes: FileWrapper(regularFileWithContents: project.configuration.storage.dataTypesAsData()),
        Filenames.regions: FileWrapper(regularFileWithContents: project.configuration.storage.regionsAsData()),
      ])
      configuration.preferredFilename = Filenames.configurationDir
      documentFileWrapper.addFileWrapper(configuration)
    }

    if let romData = project.romData, fileWrappers[Filenames.rom] == nil {
      let fileWrapper = FileWrapper(regularFileWithContents: romData)
      fileWrapper.preferredFilename = Filenames.rom
      documentFileWrapper.addFileWrapper(fileWrapper)
    }

    if fileWrappers[Filenames.gitignore] == nil {
      let fileWrapper = FileWrapper(regularFileWithContents: """
rom.gb
disassembly/game.gb
disassembly/game.map
disassembly/game.o
disassembly/game.sym
""".data(using: .utf8)!)
      fileWrapper.preferredFilename = Filenames.gitignore
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
