//
//  ContentViewController.swift
//  gbdisui
//
//  Created by Jeff Verkoeyen on 12/2/20.
//

import Foundation
import Cocoa
import LR35902

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

  let document: ProjectDocument
  let hexViewController: HexViewController
  var bankConstraints: [NSLayoutConstraint] = []
  var fileConstraints: [NSLayoutConstraint] = []

  init(document: ProjectDocument) {
    self.document = document
    self.hexViewController = HexViewController()

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

    bankConstraints = [containerView.trailingAnchor.constraint(equalTo: self.hexViewController.view.leadingAnchor)]
    fileConstraints = [containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)]

    NSLayoutConstraint.activate([
      // Text content
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),

      // Hex viewer
      self.hexViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
      self.hexViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      self.hexViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      self.hexViewController.view.widthAnchor.constraint(equalToConstant: self.hexViewController.minimumWidth),
    ])

    showBank(bank: nil)
  }

  func showBank(bank: LR35902.Bank?) {
    guard let slice = document.slice else {
      return
    }

    if let bank = bank {
      let range = LR35902.rangeOf(bank: bank)
      let byteArray = HFBTreeByteArray()
      byteArray.insertByteSlice(slice.subslice(with: HFRange(location: UInt64(range.location), length: UInt64(range.length))),
                                in: HFRange(location: 0, length: 0))
      hexViewController.hexController.byteArray = byteArray
      hexViewController.view.isHidden = false
      NSLayoutConstraint.deactivate(fileConstraints)
      NSLayoutConstraint.activate(bankConstraints)
    } else {
      hexViewController.hexController.byteArray = HFBTreeByteArray()
      hexViewController.view.isHidden = true
      NSLayoutConstraint.deactivate(bankConstraints)
      NSLayoutConstraint.activate(fileConstraints)
    }
  }
}
