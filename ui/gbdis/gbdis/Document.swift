//
//  Document.swift
//  gbdis
//
//  Created by Jeff Verkoeyen on 11/30/20.
//

import Cocoa

struct MarkdownError: Error { }

struct ProjectMetadata: Codable {
  var somevalue: String
}

@objc(MarkdownDocument)
class MarkdownDocument: NSDocument {
  private var documentFileWrapper: FileWrapper?
  let contentViewController = ViewController()

  private struct Filenames {
    static let metadata = "metadata.plist"
  }

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
    let metadata = ProjectMetadata(somevalue: "Hello")
    let encoder = PropertyListEncoder()
    let encodedMetadata = try encoder.encode(metadata)
    let metadataFileWrapper = FileWrapper(regularFileWithContents: encodedMetadata)
    metadataFileWrapper.preferredFilename = Filenames.metadata
    documentFileWrapper.addFileWrapper(metadataFileWrapper)

    return documentFileWrapper
  }

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
