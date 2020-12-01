//
//  Document.swift
//  gbdis
//
//  Created by Jeff Verkoeyen on 11/30/20.
//

import Cocoa
import UniformTypeIdentifiers

import LR35902

struct ProjectMetadata: Codable {
  var romUrl: URL?
}

private struct Filenames {
  static let metadata = "metadata.plist"
  static let disassembly = "disassembly"
}

@objc(ProjectDocument)
class ProjectDocument: NSDocument {
  let contentViewController = ViewController()

  var disassemblyFiles: [String: Data]?

  var metadata = ProjectMetadata()

  private var documentFileWrapper: FileWrapper?

  override func makeWindowControllers() {
    let window = NSWindow(contentViewController: contentViewController)
    window.setContentSize(NSSize(width: 800, height: 600))
    let wc = NSWindowController(window: window)
    wc.contentViewController = contentViewController
    addWindowController(wc)
    window.setFrameAutosaveName("windowFrame")
    window.makeKeyAndOrderFront(nil)
  }
}

extension ProjectDocument {
  @objc func loadRom(_ sender: Any?) {
    let openPanel = NSOpenPanel()
    openPanel.allowedFileTypes = ["gb"]
    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = false
    if let window = contentViewController.view.window {
      openPanel.beginSheetModal(for: window) { response in
        if response == .OK, let url = openPanel.url {
          self.metadata.romUrl = openPanel.url

          DispatchQueue.global(qos: .userInitiated).async {
            let data = try! Data(contentsOf: url)

            let disassembly = LR35902.Disassembly(rom: data)
            let files = try! disassembly.disassembleToFiles()

            DispatchQueue.main.async {
              self.disassemblyFiles = files
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
      Swift.print(metadata)
    }
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
