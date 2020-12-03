//
//  ContentViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/2/20.
//

import Foundation
import Cocoa

final class ContentViewController: NSViewController {
  var containerView: NSScrollView?
  var textView: NSTextView?
  var textStorage = NSTextStorage() {
    didSet {
      textView?.layoutManager?.replaceTextStorage(textStorage)
      textView?.textColor = .textColor
      textView?.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
    }
  }

  override func loadView() {
    view = NSView()

    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor

    let containerView = NSTextView.scrollableTextView()
    self.containerView = containerView
    containerView.frame = view.bounds
    containerView.autoresizingMask = [.width, .height]
    containerView.hasVerticalScroller = true
    view.addSubview(containerView)

    let textView = containerView.documentView as! NSTextView
    self.textView = textView
    textView.focusRingType = .none
    textView.isEditable = false
    textView.isSelectable = true
    textView.drawsBackground = false
  }
}
