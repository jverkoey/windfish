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

  let hexViewController: HexViewController

  init(document: ProjectDocument) {
    self.hexViewController = HexViewController(document: document)

    super.init(nibName: nil, bundle: nil)

    self.addChild(self.hexViewController)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = NSView()

    self.hexViewController.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(self.hexViewController.view)

    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.textBackgroundColor.cgColor

    let containerView = NSTextView.scrollableTextView()
    self.containerView = containerView
    containerView.frame = view.bounds
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.hasVerticalScroller = true
    view.addSubview(containerView)

    let textView = containerView.documentView as! NSTextView
    self.textView = textView
    textView.focusRingType = .none
    textView.isEditable = false
    textView.isSelectable = true
    textView.drawsBackground = false

    NSLayoutConstraint.activate([
      // Text content
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: self.hexViewController.view.leadingAnchor),

      // Hex viewer
      self.hexViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
      self.hexViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      self.hexViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      self.hexViewController.view.widthAnchor.constraint(equalToConstant: self.hexViewController.minimumWidth),
    ])
  }
}
