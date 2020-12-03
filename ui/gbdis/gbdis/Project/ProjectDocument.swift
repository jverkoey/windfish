//
//  Document.swift
//  gbdis
//
//  Created by Jeff Verkoeyen on 11/30/20.
//

import Cocoa

import LR35902

struct ProjectMetadata: Codable {
  var romUrl: URL
  var numberOfBanks: LR35902.Bank
  var bankMap: [String: LR35902.Bank]
}

private struct Filenames {
  static let metadata = "metadata.plist"
  static let rom = "rom.gb"
  static let disassembly = "disassembly"
}

@objc(ProjectDocument)
class ProjectDocument: NSDocument {
  weak var contentViewController: ProjectViewController?

  var romData: Data?
  var slice: HFSharedMemoryByteSlice?
  var disassemblyFiles: [String: Data]?

  var metadata: ProjectMetadata?

  private var documentFileWrapper: FileWrapper?

  override func makeWindowControllers() {
    let contentViewController = ProjectViewController(document: self)
    self.contentViewController = contentViewController
    let window = NSWindow(contentViewController: contentViewController)
    window.setContentSize(NSSize(width: 800, height: 600))
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
  static let leadingSidebarTrackingSeperator = NSToolbarItem.Identifier(rawValue: "leadingSidebarTrackingSeperator")
  static let trailingSidebarTrackingSeperator = NSToolbarItem.Identifier(rawValue: "trailingSidebarTrackingSeperator")
}

extension ProjectDocument: NSToolbarDelegate {
  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      .leadingSidebarTrackingSeperator,
      .trailingSidebarTrackingSeperator,
    ]
  }

  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      .leadingSidebarTrackingSeperator,
      .trailingSidebarTrackingSeperator,
    ]
  }

  func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    switch itemIdentifier {
    case .leadingSidebarTrackingSeperator:
      return NSTrackingSeparatorToolbarItem(
        identifier: itemIdentifier,
        splitView: contentViewController!.splitViewController.splitView,
        dividerIndex: 0
      )
    case .trailingSidebarTrackingSeperator:
      return NSTrackingSeparatorToolbarItem(
        identifier: itemIdentifier,
        splitView: contentViewController!.splitViewController.splitView,
        dividerIndex: 1
      )
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
          self.contentViewController?.startProgressIndicator()

          DispatchQueue.global(qos: .userInitiated).async {
            let data = try! Data(contentsOf: url)

            let disassembly = LR35902.Disassembly(rom: data)
            disassembly.disassembleAsGameboyCartridge()
            let disassembledSource = try! disassembly.generateSource()

            let bankMap: [String: LR35902.Bank] = disassembledSource.sources.reduce(into: [:], { accumulator, element in
              if case .bank(let number, _) = element.value {
                accumulator[element.key] = number
              }
            })
            let disassemblyFiles: [String: Data] = disassembledSource.sources.mapValues {
              switch $0 {
              case .bank(_, let content): fallthrough
              case .charmap(content: let content): fallthrough
              case .datatypes(content: let content): fallthrough
              case .game(content: let content): fallthrough
              case .macros(content: let content): fallthrough
              case .makefile(content: let content): fallthrough
              case .variables(content: let content):
                return content.data(using: .utf8)!
              }
            }

            let metadata = ProjectMetadata(
              romUrl: url,
              numberOfBanks: disassembly.cpu.numberOfBanks,
              bankMap: bankMap
            )

            DispatchQueue.main.async {
              self.romData = data
              self.slice = HFSharedMemoryByteSlice(unsharedData: data)
              self.disassemblyFiles = disassemblyFiles
              self.metadata = metadata

              NotificationCenter.default.post(name: .disassembled, object: self)

              self.contentViewController?.stopProgressIndicator()
            }
          }
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

    if let fileWrapper = fileWrappers[Filenames.rom],
       let data = fileWrapper.regularFileContents {
      self.romData = data
      self.slice = HFSharedMemoryByteSlice(unsharedData: data)
    }

    if let fileWrapper = fileWrappers[Filenames.disassembly] {
      self.disassemblyFiles = fileWrapper.fileWrappers?.mapValues {
        $0.regularFileContents!
      }
    }

    NotificationCenter.default.post(name: .disassembled, object: self)
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
