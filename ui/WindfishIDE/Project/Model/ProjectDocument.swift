import AppKit
import Foundation
import Cocoa

import RGBDS
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
    return sameboy.pc
  }
  var bank: Gameboy.Cartridge.Bank {
    return Gameboy.Cartridge.Bank(truncatingIfNeeded: sameboy.romBank)
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
        self.project.configuration.scripts = files.map({ key, value in
          Script(name: NSString(string: key).deletingPathExtension, source: String(data: value, encoding: .utf8)!)
        })
      }
      if let macros = configuration.fileWrappers?[Filenames.macrosDir],
         let files = macros.fileWrappers?.mapValues({ $0.regularFileContents! }) {
        self.project.configuration.macros = files.map({ key, value in
          Macro(name: NSString(string: key).deletingPathExtension, source: String(data: value, encoding: .utf8)!)
        })
      }
      if let globals = configuration.fileWrappers?[Filenames.globals],
         let content = globals.regularFileContents {
        let globalText = String(data: content, encoding: .utf8)!
        var globals: [Global] = []
        globalText.enumerateLines { line, _ in
          if line.isEmpty {
            return
          }
          let codeAndComments = line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
          let code = codeAndComments[0]
          if !code.contains(" EQU ") {
            return
          }
          let definitionParts = code.components(separatedBy: " EQU ")
          let name = definitionParts[0].trimmed()
          let addressText = definitionParts[1].trimmed()
          let address: LR35902.Address
          if addressText.starts(with: "$") {
            address = LR35902.Address(addressText.dropFirst(), radix: 16)!
          } else {
            return
          }
          let comments = codeAndComments[1].trimmed()
          let scanner = Scanner(string: comments)
          _ = scanner.scanUpToString("[")
          _ = scanner.scanString("[")
          let dataType = scanner.scanUpToString("]")!.trimmed()
          globals.append(Global(name: name, address: address, dataType: dataType))
        }
        self.project.configuration.globals = globals
      }
      if let dataTypes = configuration.fileWrappers?[Filenames.dataTypes],
         let content = dataTypes.regularFileContents {
        let dataTypesText = String(data: content, encoding: .utf8)!
        var dataTypes: [DataType] = []

        var dataType = DataType(name: "", representation: "", interpretation: "", mappings: [])

        dataTypesText.enumerateLines { line, _ in
          let trimmedLine = line.trimmed()
          if trimmedLine.isEmpty {
            if !dataType.name.isEmpty {
              dataTypes.append(dataType)
            }
            dataType = DataType(name: "", representation: "", interpretation: "", mappings: [])
            return
          }
          if trimmedLine.starts(with: ";") {
            // New data type definition
            let scanner = Scanner(string: trimmedLine)
            _ = scanner.scanString(";")
            dataType.name = scanner.scanUpToString("[")!.trimmed()
            _ = scanner.scanString("[")
            dataType.interpretation = scanner.scanUpToString("]")!.trimmed()
            _ = scanner.scanString("]")
            _ = scanner.scanUpToString("[")
            _ = scanner.scanString("[")
            dataType.representation = scanner.scanUpToString("]")!.trimmed()
            return
          }
          let codeAndComments = line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
          let code = codeAndComments[0]
          if !code.contains(" EQU ") {
            return
          }
          let definitionParts = code.components(separatedBy: " EQU ")
          let name = definitionParts[0].trimmed()
          let valueText = definitionParts[1].trimmed()
          let value: UInt8
          if valueText.starts(with: RGBDS.NumericPrefix.hexadecimal.rawValue) {
            value = UInt8(valueText.dropFirst(), radix: 16)!
          } else if valueText.starts(with: RGBDS.NumericPrefix.binary.rawValue) {
            value = UInt8(valueText.dropFirst(), radix: 2)!
          } else {
            value = UInt8(valueText)!
          }
          dataType.mappings.append(DataType.Mapping(name: name, value: value))
        }
        if !dataType.name.isEmpty {
          dataTypes.append(dataType)
        }
        self.project.configuration.dataTypes = dataTypes
      }
      if let regions = configuration.fileWrappers?[Filenames.regions],
         let content = regions.regularFileContents {
        let regionsText = String(data: content, encoding: .utf8)!
        var regions: [Region] = []
        regionsText.enumerateLines { line, _ in
          if line.isEmpty {
            return
          }
          let codeAndComments = line.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
          let code = codeAndComments[0].trimmed()
          if !code.hasSuffix(":") {
            return
          }
          let name = String(code.dropLast())
          let comments = codeAndComments[1].trimmed()
          let scanner = Scanner(string: comments)
          _ = scanner.scanUpToString("[")
          _ = scanner.scanString("[")
          let regionType = scanner.scanUpToString("]")!.trimmed()
          _ = scanner.scanUpToString("$")
          _ = scanner.scanString("$")
          let bank = scanner.scanUpToString(":")!.trimmed()
          _ = scanner.scanUpToString("$")
          _ = scanner.scanString("$")
          let address = scanner.scanUpToString("[")!.trimmed()
          _ = scanner.scanString("[")
          let length = scanner.scanUpToString("]")!.trimmed()
          regions.append(Region(regionType: regionType,
                                name: name,
                                bank: Gameboy.Cartridge.Bank(bank, radix: 16)!,
                                address: LR35902.Address(address, radix: 16)!,
                                length: LR35902.Address(length)!))
        }
        self.project.configuration.regions = regions
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
        Filenames.scriptsDir: FileWrapper(directoryWithFileWrappers: project.configuration.scripts.reduce(into: [:]) { accumulator, script in
          accumulator[script.name + ".js"] = FileWrapper(regularFileWithContents: script.source.data(using: .utf8)!)
        }),
        Filenames.macrosDir: FileWrapper(directoryWithFileWrappers: project.configuration.macros.reduce(into: [:]) { accumulator, macro in
          accumulator[macro.name + ".asm"] = FileWrapper(regularFileWithContents: macro.source.data(using: .utf8)!)
        }),
        Filenames.globals: FileWrapper(regularFileWithContents: project.configuration.globals
                                        .sorted(by: { $0.address < $1.address })
                                        .map { (global: Global) -> String in
                                          "\(global.name) EQU $\(global.address.hexString) ; [\(global.dataType)]"
                                        }.joined(separator: "\n\n").data(using: .utf8)!),
        Filenames.dataTypes: FileWrapper(regularFileWithContents: project.configuration.dataTypes
                                          .sorted(by: { $0.name < $1.name })
                                          .map { (dataType: DataType) -> String in
                                            (["; \(dataType.name) [\(dataType.interpretation)] [\(dataType.representation)]"]
                                              + dataType.mappings.map { (mapping: DataType.Mapping) -> String in
                                                switch dataType.representation {
                                                case DataType.Representation.binary:
                                                  return "\(mapping.name) EQU \(RGBDS.NumericPrefix.binary.rawValue)\(mapping.value.binaryString)"
                                                case DataType.Representation.hexadecimal:
                                                  return "\(mapping.name) EQU \(RGBDS.NumericPrefix.hexadecimal.rawValue)\(mapping.value.hexString)"
                                                case DataType.Representation.decimal:
                                                  return "\(mapping.name) EQU \(mapping.value)"
                                                default:
                                                  fatalError()
                                                }
                                              }).joined(separator: "\n")
                                          }.joined(separator: "\n\n").data(using: .utf8)!),
        Filenames.regions: FileWrapper(regularFileWithContents: project.configuration.regions
                                        .sorted(by: { $0.bank < $1.bank && $0.address < $1.address })
                                        .map { (region: Region) -> String in
                                          "\(region.name): ; [\(region.regionType)] $\(region.bank.hexString):$\(region.address.hexString) [\(region.length)]"
                                        }.joined(separator: "\n\n").data(using: .utf8)!),
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
