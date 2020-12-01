//
//  Document.swift
//  gbdis
//
//  Created by Jeff Verkoeyen on 11/30/20.
//

import Cocoa

struct MarkdownError: Error { }

@objc(MarkdownDocument)
class MarkdownDocument: NSDocument {
  private var fileWrapper: FileWrapper?
  let contentViewController = ViewController()

  override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {

  }

  override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
    return FileWrapper()
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
